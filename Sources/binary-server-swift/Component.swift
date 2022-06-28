//
//  Component.swift
//  
//
//  Created by lzh on 2022/6/28.
//

import Vapor

struct Component: Content {
    let file: File?
    let name: String
    let version: String
    let annotate: String?
    let sha: String?
    let md5: String?
    var createTimeStamp: Date?
    
    mutating func afterDecode() throws {
        if createTimeStamp == nil {
            createTimeStamp = .now
        }
    }
    
    func mongo() -> Component {
        Component(file: nil,
                  name: name,
                  version: version,
                  annotate: annotate,
                  sha: sha,
                  md5: md5,
                  createTimeStamp: createTimeStamp)
    }
}
