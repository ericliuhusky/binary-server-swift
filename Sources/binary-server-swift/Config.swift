//
//  Config.swift
//  
//
//  Created by lzh on 2022/6/30.
//

import Vapor


fileprivate let frameworkDirectoryName = ".binary"
fileprivate let frameworkDatabaseName = "binary_database"
fileprivate let frameworkCollectionName = "components"
fileprivate let testDirectoryName = ".test"
fileprivate let testDatabaseName = "test_database"
fileprivate let testCollectionName = "test"


struct Config {
    static var directoryName = frameworkDirectoryName
    static var databaseName = frameworkDatabaseName
    static var collectionName = frameworkCollectionName
    
    static func configure(_ app: Application) {
        app.routes.defaultMaxBodySize = "3gb"
        
        if app.environment.name == "testing" {
            Config.directoryName = testDirectoryName
            Config.databaseName = testDatabaseName
            Config.collectionName = testCollectionName
        }
    }
}
