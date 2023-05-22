import Vapor
import RoutingKit
import CodeSharing

public struct HTTPRequest<InputBody, Parameters> {
    public let body: InputBody
    public let parameters: Parameters
}

public struct HTTPResponse<OutputBody> {
    public let body: OutputBody
}

public typealias HTTPHandler<InputBody, OutputBody, Parameters> = (HTTPRequest<InputBody, Parameters>) async throws -> HTTPResponse<OutputBody>
public typealias HTTPContentHandler<InputBody, OutputBody, Parameters> = (HTTPRequest<InputBody, Parameters>) async throws -> OutputBody

extension RoutesBuilder {
    public func register<InputBody: Content, OutputBody: Content, Parameters>(
        _ endpoint: HTTPEndpoint<InputBody, OutputBody, Parameters>,
        perform: @escaping HTTPHandler<InputBody, OutputBody, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            let body = try req.content.decode(InputBody.self)
            let response = try await perform(.init(body: body, parameters: parameters))
            return response.body
        }
    }
    
    public func register<OutputBody: Content, Parameters>(
        _ endpoint: HTTPEndpoint<Void, OutputBody, Parameters>,
        perform: @escaping HTTPHandler<Void, OutputBody, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            let response = try await perform(.init(body: (), parameters: parameters))
            return response.body
        }
    }
    
    public func register<InputBody: Content, Parameters>(
        _ endpoint: HTTPEndpoint<InputBody, Void, Parameters>,
        perform: @escaping HTTPHandler<InputBody, Void, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            let body = try req.content.decode(InputBody.self)
            let response = try await perform(.init(body: body, parameters: parameters))
            return Response(status: .ok)
        }
    }
    
    public func register<Parameters>(
        _ endpoint: HTTPEndpoint<Void, Void, Parameters>,
        perform: @escaping HTTPHandler<Void, Void, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            let response = try await perform(.init(body: (), parameters: parameters))
            return Response(status: .ok)
        }
    }
    
    public func register<InputBody: Content, OutputBody: Content, Parameters>(
        _ endpoint: HTTPEndpoint<InputBody, OutputBody, Parameters>,
        perform: @escaping HTTPContentHandler<InputBody, OutputBody, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            let body = try req.content.decode(InputBody.self)
            return try await perform(.init(body: body, parameters: parameters))
        }
    }
    
    public func register<OutputBody: Content, Parameters>(
        _ endpoint: HTTPEndpoint<Void, OutputBody, Parameters>,
        perform: @escaping HTTPContentHandler<Void, OutputBody, Parameters>
    ) {
        var path = [RoutingKit.PathComponent]()
        var parameterCount = 0
        
        for component in endpoint.path {
            switch component {
            case .constant(let constant):
                path.append(.constant(constant))
            case .parameter:
                path.append(.parameter("p\(parameterCount)"))
                parameterCount += 1
            }
        }
        
        self.on(.init(rawValue: endpoint.method), path) { req in
            var parameterStrings = [String]()
            for i in 0..<parameterCount {
                try parameterStrings.append(req.parameters.require("p\(i)"))
            }
            
            let parameters = try endpoint.readParameters(&parameterStrings)
            return try await perform(.init(body: (), parameters: parameters))
        }
    }
}
