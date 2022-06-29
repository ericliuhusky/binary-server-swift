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
app.post("frameworks") { req -> Response in
    let framework = try req.content.decode(Framework.self)
    
    if try await req.frameworkCollection.contains(framework) {
        return Response(status: .conflict, body: Response.Body(string: "二进制文件已存在 \(framework.name) (\(framework.version))\n"))
    }
    
    try await req.frameworkCollection.insertOne(framework.mongo())
    
    
    
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
    try await req.fileio.writeFile(file.data, at: path)
    
    return Response(status: .created, body: Response.Body(string: "保存成功 \(framework.name) (\(framework.version))\n"))
}

app.get("") { req -> String in
    return "suc"
}

app.get("frameworks") { req -> String in
    return "suc"
}

app.get("frameworks", ":name") { req -> String in
    return "suc"
}

app.get("frameworks", ":name", ":version") { req -> String in
    var filter = BSONDocument()
    if let name = req.parameters.get("name") {
        if let version = req.parameters.get("version") {
            filter = ["name": .string(name),
                      "version": .string(version)]
        } else {
            let names = name.split(separator: ",").map { BSON.string(String($0)) }
            filter = ["name": .array(names)]
        }
    }
    let frameworks = try await req.frameworkCollection.find(filter).toArray()
    
    var dict = [String: [String]]()
    frameworks.forEach { framework in
        dict[framework.name] = dict[framework.name] ?? []
        dict[framework.name]?.append(framework.version)
    }
    let jsonData = try JSONSerialization.data(withJSONObject: dict)
    let jsonStr = String(data: jsonData, encoding: .utf8) ?? "{}"
    return jsonStr + "\n"
}

app.get("frameworks", ":name", ":version", "zip") { req -> Response in
    guard
        let name = req.parameters.get("name"),
        let version = req.parameters.get("version")
    else {
        return Response(status: .badRequest, body: "")
    }
    
    if try await !req.frameworkCollection.contains(name: name, version: version) {
        return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
    }
    
    let binaryDirectory = binaryRootDirectory.appendingPathComponent(name).appendingPathComponent(version)
    guard let file = try FileManager.default.contentsOfDirectory(atPath: binaryDirectory.path).first else {
        return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
    }
    
    let path = binaryDirectory.appendingPathComponent(file).path
    
    return req.fileio.streamFile(at: path)
}

app.get("frameworks", ":name", ":version", ".tgz") { req in
    return "suc"
}

app.delete("frameworks", ":name", ":version") { req -> Response in
    guard
        let name = req.parameters.get("name"),
        let version = req.parameters.get("version")
    else {
        return Response(status: .badRequest, body: "")
    }
    
    if try await !req.frameworkCollection.contains(name: name, version: version) {
        return Response(status: .notFound, body: Response.Body(string: "无二进制文件 \(name) (\(version))\n"))
    }
    
    try await req.frameworkCollection.deleteOne(["name": .string(name),
                                                 "version": .string(version)])
    
    
    let binaryDirectory = binaryRootDirectory.appendingPathComponent(name).appendingPathComponent(version)
    
    if FileManager.default.fileExists(atPath: binaryDirectory.path) {
        try FileManager.default.removeItem(at: binaryDirectory)
    }
    
    return Response(status: .ok, body: Response.Body(string: "删除成功 \(name) (\(version))\n"))
}

try app.run()

extension Request {
    var frameworkCollection: MongoCollection<Framework> {
        application.mongoDB.client.db("binary_database").collection("components", withType: Framework.self)
    }
}
