import CodeSharing

struct Unimplemented: Error {}

public struct HTTPRequest<InputBody, Parameters> {
    public let body: InputBody
    public let parameters: Parameters
}

public struct HTTPResponse<OutputBody> {
    public let body: OutputBody
}

public typealias SpoofHTTPHandler<InputBody, OutputBody, Parameters> = (HTTPRequest<InputBody, Parameters>) async throws -> HTTPResponse<OutputBody>
public typealias SpoofStrippedHTTPHandler<InputBody, OutputBody, Parameters> = (HTTPRequest<InputBody, Parameters>) async throws -> OutputBody
public struct SpoofHTTPServer {
    public typealias AnyHandler = Any
    
    public var handlers = [ObjectIdentifier: AnyHandler]()
    
    public init() {}
    
    public mutating func addHandler<InputBody, OutputBody, Parameters>(
        to endpoint: HTTPEndpoint<InputBody, OutputBody, Parameters>,
        _ perform: @escaping SpoofHTTPHandler<InputBody, OutputBody, Parameters>
    ) {
        let id = ObjectIdentifier(HTTPEndpoint<InputBody, OutputBody, Parameters>.self)
        handlers[id] = perform
    }
    
    public mutating func addHandler<InputBody, OutputBody, Parameters>(
        to endpoint: HTTPEndpoint<InputBody, OutputBody, Parameters>,
        _ perform: @escaping SpoofStrippedHTTPHandler<InputBody, OutputBody, Parameters>
    ) {
        addHandler(to: endpoint) { request in
            return try await HTTPResponse(body: perform(request))
        }
    }
}

public struct SpoofHTTPClient {
    let server: SpoofHTTPServer
    
    public init(server: SpoofHTTPServer) {
        self.server = server
    }
    
    public func request<OutputBody>(_ endpoint: HTTPEndpoint<Void, OutputBody, Void>) async throws -> HTTPResponse<OutputBody> {
        let id = ObjectIdentifier(HTTPEndpoint<Void, OutputBody, Void>.self)
        
        guard let handler = server.handlers[id] as? SpoofHTTPHandler<Void, OutputBody, Void> else {
            throw Unimplemented()
        }
        
        return try await handler(HTTPRequest(body: (), parameters: ()))
    }
    
    public func request<OutputBody, P0>(
        _ endpoint: HTTPEndpoint<Void, OutputBody, P0>,
        parameters p0: P0
    ) async throws -> HTTPResponse<OutputBody> {
        let id = ObjectIdentifier(HTTPEndpoint<Void, OutputBody, P0>.self)
        
        guard let handler = server.handlers[id] as? SpoofHTTPHandler<Void, OutputBody, P0> else {
            throw Unimplemented()
        }
        
        return try await handler(HTTPRequest(body: (), parameters: p0))
    }
    
    public func request<OutputBody, P0, P1>(
        _ endpoint: HTTPEndpoint<Void, OutputBody, (P0, P1)>,
        parameters p0: P0,
        _ p1: P1
    ) async throws -> HTTPResponse<OutputBody> {
        let id = ObjectIdentifier(HTTPEndpoint<Void, OutputBody, (P0, P1)>.self)
        
        guard let handler = server.handlers[id] as? SpoofHTTPHandler<Void, OutputBody, (P0, P1)> else {
            throw Unimplemented()
        }
        
        return try await handler(HTTPRequest(body: (), parameters: (p0, p1)))
    }
}
