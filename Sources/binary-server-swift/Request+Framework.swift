//
//  Request+Framework.swift
//  
//
//  Created by lzh on 2022/6/29.
//

import Vapor
import MongoDBVapor

extension Request {
    var frameworkCollection: MongoCollection<Framework> {
        application.mongoDB.client.db(frameworkDatabaseName).collection(frameworkCollectionName, withType: Framework.self)
    }
    
    func addFramework() async throws -> Response {
        let framework = try content.decode(Framework.self)
        
        if try await frameworkCollection.contains(framework) {
            return .conflict(message: .fileAlreadyExists, other: "\(framework.name) (\(framework.version))")
        }
        
        try await frameworkCollection.insertOne(framework.mongo())
        
        
        let directory = app.directory.directory(framework)
        if !FileManager.default.fileExists(atPath: directory) {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        }
        guard let file = framework.file else {
            return .badRequest(message: .notFoundFileInBody)
        }
        
        guard framework.isMD5Validated else {
            return .badRequest(message: .notMD5Validated)
        }
        
        guard framework.isSHAValidated else {
            return .badRequest(message: .notSHAValidated)
        }
        
        
        let path = app.directory.directory(framework, filename: file.filename)
        try await fileio.writeFile(file.data, at: path)
        
        return .created(message: .createSuccess, other: "\(framework.name) (\(framework.version))")
    }
    
    func findFrameworks() async throws -> [Framework] {
        var filter = BSONDocument()
        if let name = parameters.get("name") {
            if let version = parameters.get("version") {
                filter = ["name": .string(name),
                          "version": .string(version)]
            } else {
                let names = name.split(separator: ",").map { BSON.string(String($0)) }
                filter = ["name": ["$in": .array(names)]]
            }
        }
        return try await frameworkCollection.find(filter).toArray()
    }
    
    func downloadFramework() async throws -> Response {
        guard
            let name = parameters.get("name"),
            let version = parameters.get("version")
        else {
            return .badRequest(message: .missingParameters)
        }
        
        if try await !frameworkCollection.contains(name: name, version: version) {
            return .notFound(message: .notFoundFileInDatabase, other: "\(name) (\(version))")
        }
        
        let directory = app.directory.directory(name: name, version: version)
        guard let file = try FileManager.default.contentsOfDirectory(atPath: directory).first else {
            return .notFound(message: .notFoundFileOnDisk, other: "\(name) (\(version))")
        }
        
        let path = app.directory.directory(name: name, version: version, filename: file)
        
        return fileio.streamFile(at: path)
    }
    
    func deleteFramework() async throws -> Response {
        guard
            let name = parameters.get("name"),
            let version = parameters.get("version")
        else {
            return .badRequest(message: .missingParameters)
        }
        
        if try await !frameworkCollection.contains(name: name, version: version) {
            return .notFound(message: .notFoundFileInDatabase, other: "\(name) (\(version))")
        }
        
        try await frameworkCollection.deleteOne(["name": .string(name),
                                                 "version": .string(version)])
        
        
        let directory = app.directory.directory(name: name, version: version)
        
        if FileManager.default.fileExists(atPath: directory) {
            try FileManager.default.removeItem(atPath: directory)
        }
        
        return .ok(message: .deleteSuccess, other: "\(name) (\(version))")
    }
}
