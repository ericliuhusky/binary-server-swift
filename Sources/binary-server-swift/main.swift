import Vapor
import MongoDBVapor


let app = try Application(.detect())
try app.mongoDB.configure()

defer {
    app.mongoDB.cleanup()
    cleanupMongoSwift()
    app.shutdown()
}

configure(app)

frameworkAPIRoutes(app)

app.get { req -> String in
    let frameworks = try await req.findFrameworks()
    return try show(frameworks)
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
