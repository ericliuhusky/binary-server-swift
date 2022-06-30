//
//  configure.swift
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

var directoryName = frameworkDirectoryName
var databaseName = frameworkDatabaseName
var collectionName = frameworkCollectionName

func configure(_ app: Application) {
    app.routes.defaultMaxBodySize = "3gb"
    
    if app.environment.name == "testing" {
        directoryName = testDirectoryName
        databaseName = testDatabaseName
        collectionName = testCollectionName
    }
}
