//
//  routes.swift
//  
//
//  Created by lzh on 2022/6/30.
//

import Vapor

func frameworkAPIRoutes(_ app: Application) {
    let frameworks = app.grouped("frameworks")
    
    frameworks.post { req in
        try await req.addFramework(app)
    }
    
    frameworks.get { req -> String in
        let frameworks = try await req.findFrameworks()
        return try show(frameworks)
    }
    
    frameworks.get(":name") { req -> String in
        let frameworks = try await req.findFrameworks()
        return try show(frameworks)
    }
    
    frameworks.get(":name", ":version") { req -> String in
        let frameworks = try await req.findFrameworks()
        return try show(frameworks)
    }
    
    frameworks.get(":name", ":version", "zip") { req in
        try await req.downloadFramework(app)
    }
    
    frameworks.get(":name", ":version", ".tgz") { req in
        try await req.downloadFramework(app)
    }
    
    frameworks.delete(":name", ":version") { req in
        try await req.deleteFramework(app)
    }
}
