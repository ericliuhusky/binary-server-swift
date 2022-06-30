import XCTest
@testable import binary_server_swift
import XCTVapor
import MongoDBVapor

final class binary_server_swiftTests: XCTestCase {
    let app = Application(.testing)
    
    var frameworkCollection: MongoCollection<Framework> {
        app.mongoDB.client
            .db(Config.databaseName)
            .collection(Config.collectionName, withType: Framework.self)
    }
    
    let framework = Framework(file: File(data: "Hello, world!\n", filename: "filename"),
                              name: "name", version: "1.0",
                              annotate: nil, sha: nil, md5: nil)
    
    func testFramework() async throws {
        try app.mongoDB.configure()
        defer {
            app.mongoDB.cleanup()
            cleanupMongoSwift()
            app.shutdown()
        }
        
        Config.configure(app)
        frameworkAPIRoutes(app)
        
        
        
        try await addFramework()
        try await findFrameworks()
        try downloadFramework()
        try await deleteFramework()
        
        
        try await app.mongoDB.client.db(Config.databaseName).drop()
        try FileManager.default.removeItem(at: URL(fileURLWithPath: app.directory.frameworkDirectory))
    }
    
    func addFramework() async throws {
        try await app.test(.POST, "frameworks", beforeRequest: { req in
            try req.content.encode(framework)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            
            let isExisted = try await frameworkCollection.contains(framework)
            XCTAssert(isExisted)
            XCTAssert(FileManager.default.fileExists(atPath: app.directory.directory(framework)))
        })
    }
    
    func findFrameworks() async throws {
        try await app.test(.GET, "frameworks", afterResponse: { res in
            let frameworks = try await frameworkCollection.find().toArray()
            XCTAssertEqual(res.body.string, try show(frameworks))
        })
        
        try await app.test(.GET, "frameworks/name", afterResponse: { res in
            let frameworks = try await frameworkCollection.find(["name": "name"]).toArray()
            XCTAssertEqual(res.body.string, try show(frameworks))
        })
        
        try await app.test(.GET, "frameworks/name/1.0", afterResponse: { res in
            let frameworks = try await frameworkCollection.find(["name": "name",
                                                                 "version": "1.0"]).toArray()
            XCTAssertEqual(res.body.string, try show(frameworks))
        })
    }
    
    func downloadFramework() throws {
        try app.test(.GET, "frameworks/name/1.0/zip", afterResponse: { res in
            let directory = app.directory.directory(framework)
            let file = try FileManager.default.contentsOfDirectory(atPath: directory).first!
            let data = try Data(contentsOf: URL(fileURLWithPath: directory).appendingPathComponent(file))
            XCTAssertEqual(Data(buffer: res.body), data)
        })
    }
    
    func deleteFramework() async throws {
        try await app.test(.DELETE, "frameworks/name/1.0", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let isExisted = try await frameworkCollection.contains(framework)
            XCTAssert(!isExisted)
            XCTAssert(!FileManager.default.fileExists(atPath: app.directory.directory(framework)))
        })
    }
}
