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
        application.mongoDB.client.db("binary_database").collection("components", withType: Framework.self)
    }
    
    func addFramework() async throws -> Response {
        let framework = try content.decode(Framework.self)
        
        if try await frameworkCollection.contains(framework) {
            return Response(status: .conflict, body: Response.Body(string: "二进制文件已存在 \(framework.name) (\(framework.version))\n"))
        }
        
        try await frameworkCollection.insertOne(framework.mongo())
        
        
        
        let binaryDirectory = binaryRootDirectory.appendingPathComponent(framework.name).appendingPathComponent(framework.version)
        if !FileManager.default.fileExists(atPath: binaryDirectory.path) {
            try FileManager.default.createDirectory(at: binaryDirectory, withIntermediateDirectories: true)
        }
        guard let file = framework.file else {
            return Response(status: .badRequest, body: "没有上传文件\n")
        }
        
        guard framework.isMD5Validated else {
            return Response(status: .badRequest, body: Response.Body(string: "md5值不符\n"))
        }
        
        guard framework.isSHAValidated else {
            return Response(status: .badRequest, body: Response.Body(string: "sha值不符\n"))
        }
        
        
        let path = binaryDirectory.appendingPathComponent(file.filename).path
        try await fileio.writeFile(file.data, at: path)
        
        return Response(status: .created, body: Response.Body(string: "保存成功 \(framework.name) (\(framework.version))\n"))
    }
    
    func findFrameworks() async throws -> [Framework] {
        var filter = BSONDocument()
        if let name = parameters.get("name") {
            if let version = parameters.get("version") {
                filter = ["name": .string(name),
                          "version": .string(version)]
            } else {
                let names = name.split(separator: ",").map { BSON.string(String($0)) }
                filter = ["name": .array(names)]
            }
        }
        return try await frameworkCollection.find(filter).toArray()
    }
    
    func downloadFramework() async throws -> Response {
        guard
            let name = parameters.get("name"),
            let version = parameters.get("version")
        else {
            return Response(status: .badRequest, body: "")
        }
        
        if try await !frameworkCollection.contains(name: name, version: version) {
            return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
        }
        
        let binaryDirectory = binaryRootDirectory.appendingPathComponent(name).appendingPathComponent(version)
        guard let file = try FileManager.default.contentsOfDirectory(atPath: binaryDirectory.path).first else {
            return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
        }
        
        let path = binaryDirectory.appendingPathComponent(file).path
        
        return fileio.streamFile(at: path)
    }
    
    func deleteFramework() async throws -> Response {
        guard
            let name = parameters.get("name"),
            let version = parameters.get("version")
        else {
            return Response(status: .badRequest, body: "")
        }
        
        if try await !frameworkCollection.contains(name: name, version: version) {
            return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
        }
        
        try await frameworkCollection.deleteOne(["name": .string(name),
                                                     "version": .string(version)])
        
        
        let binaryDirectory = binaryRootDirectory.appendingPathComponent(name).appendingPathComponent(version)
        
        if FileManager.default.fileExists(atPath: binaryDirectory.path) {
            try FileManager.default.removeItem(at: binaryDirectory)
        }
        
        return Response(status: .ok, body: Response.Body(string: "删除成功 \(name) (\(version))\n"))
    }
}
