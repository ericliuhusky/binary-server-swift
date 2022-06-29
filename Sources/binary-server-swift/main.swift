import Vapor
import MongoDBVapor


let app = try Application(.detect())
try app.mongoDB.configure()

defer {
    app.mongoDB.cleanup()
    cleanupMongoSwift()
    app.shutdown()
}

let binaryRootDirectory = URL(fileURLWithPath: app.directory.workingDirectory).appendingPathComponent(".binary")

app.routes.defaultMaxBodySize = "3gb"
app.post("frameworks") { req in
    try await req.addFramework()
}

app.get("") { req -> String in
    let frameworks = try await req.findFrameworks()
    return try show(frameworks)
}

app.get("frameworks") { req -> String in
    let frameworks = try await req.findFrameworks()
    return try show(frameworks)
}

app.get("frameworks", ":name") { req -> String in
    let frameworks = try await req.findFrameworks()
    return try show(frameworks)
}

app.get("frameworks", ":name", ":version") { req -> String in
    let frameworks = try await req.findFrameworks()
    return try show(frameworks)
}

app.get("frameworks", ":name", ":version", "zip") { req -> Response in
    try await req.downloadFramework()
}

app.get("frameworks", ":name", ":version", ".tgz") { req in
    try await req.downloadFramework()
}

app.delete("frameworks", ":name", ":version") { req -> Response in
    try await req.deleteFramework()
}

try app.run()


func show(_ frameworks: [Framework]) throws -> String {
    var dict = [String: [String]]()
    frameworks.forEach { framework in
        dict[framework.name] = dict[framework.name] ?? []
        dict[framework.name]?.append(framework.version)
    }
    let jsonData = try JSONSerialization.data(withJSONObject: dict)
    let jsonStr = String(data: jsonData, encoding: .utf8) ?? "{}"
    return jsonStr + "\n"
}
