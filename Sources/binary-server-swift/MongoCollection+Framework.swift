//
//  MongoCollection+Framework.swift
//  
//
//  Created by lzh on 2022/6/29.
//

import MongoSwift

extension MongoCollection where T == Framework {
    func contains(_ framework: Framework) async throws -> Bool {
        try await contains(name: framework.name,
                           version: framework.version)
    }
    
    func contains(name: String, version: String) async throws -> Bool {
        try await findOne(["name": .string(name),
                           "version": .string(version)]) != nil
    }
}
