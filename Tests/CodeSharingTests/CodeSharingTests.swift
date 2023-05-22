import XCTest
import CodeSharing
import CodeSharingMock
import CodeSharingApple

import Vapor
import XCTVapor
import CodeSharingVapor

final class CodeSharingTests: XCTestCase {
    func testSimpleHello() async throws {
        struct Output: Codable {
            let bool: Bool
        }
        
        var server = SpoofHTTPServer()
        let route = HTTPEndpoint.get(Output.self) {
            "hello"
            "world"
        }
        
        XCTAssertEqual(route.path, ["hello", "world"])
        
        server.addHandler(to: route) { req in
            return Output(bool: true)
        }
        
        let result = try await SpoofHTTPClient(server: server).request(route)
        XCTAssertTrue(result.body.bool)
    }
    
    func testVapor() throws {
        // Shared between iOS/Android and Vapor
        struct Output: Content {
            let randomInt: Int
            let parameter: String
        }
        
        let route = HTTPEndpoint.get(Output.self) {
            "hello"
            String.self
        }
        
        // Vapor Logic
        let app = Application()
        
        app.register(route) { req in
            return Output(randomInt: .random(), parameter: "Hello \(req.parameters)")
        }
        
        // Client Logic
        try app.testable().test(.GET, "/hello/World") { res in
            XCTAssertContent(Output.self, res) { content in
                XCTAssertEqual(content.parameter, "Hello World")
            }
        }
        
        app.shutdown()
    }
    
    func testComponents() async throws {
        struct Output: Codable {
            let randomInt: Int
            let parameter: String
        }
        
        var server = SpoofHTTPServer()
        let route = HTTPEndpoint.get(Output.self) {
            "hello"
            String.self
        }
        
        XCTAssertEqual(route.path, ["hello", .parameter(String.self)])
        
        server.addHandler(to: route) { req in
            return Output(randomInt: .random(in: 0..<10), parameter: req.parameters)
        }
        
        let result = try await SpoofHTTPClient(server: server).request(route, parameters: "test")
        XCTAssertEqual(result.body.parameter, "test")
    }
}
