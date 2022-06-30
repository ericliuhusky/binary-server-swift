//
//  DirectoryConfiguration+Framework.swift
//  
//
//  Created by lzh on 2022/6/29.
//

import Vapor

extension DirectoryConfiguration {
    var frameworkDirectory: String {
        URL(fileURLWithPath: app.directory.workingDirectory)
            .appendingPathComponent(frameworkDirectoryName)
            .path
    }
    
    func directory(_ framework: Framework) -> String {
        directory(name: framework.name,
                  version: framework.version)
    }
    
    func directory(name: String, version: String) -> String {
        URL(fileURLWithPath: frameworkDirectory)
            .appendingPathComponent(name)
            .appendingPathComponent(version)
            .path
    }
    
    func directory(_ framework: Framework, filename: String) -> String {
        directory(name: framework.name,
                  version: framework.version,
                  filename: filename)
    }
    
    func directory(name: String, version: String, filename: String) -> String {
        URL(fileURLWithPath: directory(name: name, version: version))
            .appendingPathComponent(filename)
            .path
    }
}
