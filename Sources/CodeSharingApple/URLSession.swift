import Foundation
import CodeSharing

enum CodeSharingURLSessionError: Error {
    case invalidURL
}

extension URLSession {
    public func body<
        OutputBody: Codable
    >(
        at endpoint: HTTPEndpoint<Void, OutputBody, Void>,
        host: String
    ) async throws -> OutputBody {
        var components: [LosslessStringConvertible] = []
        guard let url = endpoint.url(forHost: host, components: &components) else {
            throw CodeSharingURLSessionError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await data(for: request)
        
        return try JSONDecoder().decode(OutputBody.self, from: data)
    }
    
    public func body<
        OutputBody: Codable,
        P0: LosslessStringConvertible
    >(
        at endpoint: HTTPEndpoint<Void, OutputBody, P0>,
        host: String,
        parameters p0: P0
    ) async throws -> OutputBody {
        var components: [LosslessStringConvertible] = [
            p0
        ]
        
        guard let url = endpoint.url(forHost: host, components: &components) else {
            throw CodeSharingURLSessionError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await data(for: request)
        
        return try JSONDecoder().decode(OutputBody.self, from: data)
    }
    
    public func body<
        OutputBody: Codable,
        P0: LosslessStringConvertible,
        P1: LosslessStringConvertible
    >(
        at endpoint: HTTPEndpoint<Void, OutputBody, (P0, P1)>,
        host: String,
        parameters p0: P0,
        _ p1: P1
    ) async throws -> OutputBody {
        var components: [LosslessStringConvertible] = [
            p0, p1
        ]
        
        guard let url = endpoint.url(forHost: host, components: &components) else {
            throw CodeSharingURLSessionError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await data(for: request)
        
        return try JSONDecoder().decode(OutputBody.self, from: data)
    }
}

extension HTTPEndpoint {
    func url(
        forHost host: String,
        components: inout [LosslessStringConvertible]
    ) -> URL? {
        var host = host
        
        if !host.hasPrefix("http") {
            host.insert(contentsOf: "https://", at: host.startIndex)
        }
        
        if !host.hasSuffix("/") {
            host.append("/")
        }
        
        host += path.map { component in
            switch component {
            case .constant(let constant):
                return constant
            case .parameter:
                assert(!components.isEmpty, "Unexpectedly found too few components to create the URL")
                
                let component = components.removeFirst()
                
                // TODO: Assert `component`'s type matches the parameter type
                
                return component.description
            }
        }.joined(separator: "/")
        
        return URL(string: host)
    }
}
