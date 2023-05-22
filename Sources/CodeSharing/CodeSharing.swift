public enum PathComponent: Hashable, ExpressibleByStringLiteral {
    case constant(String)
    case parameter(LosslessStringConvertible.Type)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .constant(let constant):
            constant.hash(into: &hasher)
        case .parameter(let type):
            ObjectIdentifier(type).hash(into: &hasher)
        }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.constant(let lhs), .constant(let rhs)):
            return lhs == rhs
        case (.parameter(let lhs), .parameter(let rhs)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        default:
            return false
        }
    }
    
    public init(stringLiteral value: String) {
        self = .constant(value)
    }
}

public struct HTTPEndpoint<InputBody, OutputBody, Parameters> {
    public let method: String
    public let path: [PathComponent]
    public let readParameters: (inout [String]) throws -> Parameters
}

public struct PartialPath<Parameters> {
    public var path: [PathComponent]
    public var readParameters: (inout [String]) throws -> Parameters
    
    public init(path: [PathComponent], readParameters: @escaping (inout [String]) throws -> Parameters) {
        self.path = path
        self.readParameters = readParameters
    }
}

enum ParameterResolutionError: Error {
    case unexpectedlyFoundEmptyParameterList
    case failedParameterInstantiation(type: Any.Type)
}

private func readParameter<T: LosslessStringConvertible>(from parameters: inout [String]) throws -> T {
    if parameters.isEmpty {
        throw ParameterResolutionError.unexpectedlyFoundEmptyParameterList
    }
    
    guard let parameter = T(parameters.removeFirst()) else {
        throw ParameterResolutionError.failedParameterInstantiation(type: T.self)
    }
    
    return parameter
}

@resultBuilder public struct PathBuilder {
    public static func buildPartialBlock(
        first: String
    ) -> PartialPath<Void> {
        PartialPath(path: [.constant(first)]) { _ in }
    }
    
    public static func buildPartialBlock<T: LosslessStringConvertible>(
        first: T.Type
    ) -> PartialPath<T> {
        PartialPath(path: [.parameter(first)], readParameters: readParameter)
    }
    
    public static func buildPartialBlock<P>(
        accumulated: PartialPath<P>,
        next: String
    ) -> PartialPath<P> {
        var accumulated = accumulated
        accumulated.path.append(.constant(next))
        return accumulated
    }
    
    public static func buildPartialBlock<
        T: LosslessStringConvertible
    >(
        accumulated: PartialPath<Void>,
        next: T.Type
    ) -> PartialPath<T> {
        var accumulated = PartialPath<T>(path: accumulated.path, readParameters: readParameter)
        accumulated.path.append(.parameter(next))
        return accumulated
    }
    
    @_disfavoredOverload
    public static func buildPartialBlock<
        T: LosslessStringConvertible,
        P0
    >(
        accumulated: PartialPath<P0>,
        next: T.Type
    ) -> PartialPath<(P0, T)> {
        var accumulated = PartialPath<(P0, T)>(path: accumulated.path) { parameters in
            let previous = try accumulated.readParameters(&parameters)
            let next: T = try readParameter(from: &parameters)
            return (previous, next)
        }
        accumulated.path.append(.parameter(next))
        return accumulated
    }
    
    public static func buildPartialBlock<
        T: LosslessStringConvertible,
        P0,
        P1
    >(
        accumulated: PartialPath<(P0, P1)>,
        next: T.Type
    ) -> PartialPath<(P0, P1, T)> {
        var accumulated = PartialPath<(P0, P1, T)>(path: accumulated.path) { parameters in
            let previous = try accumulated.readParameters(&parameters)
            let next: T = try readParameter(from: &parameters)
            return (previous.0, previous.1, next)
        }
        accumulated.path.append(.parameter(next))
        return accumulated
    }
    
    public static func buildPartialBlock<
        T: LosslessStringConvertible,
        P0,
        P1,
        P2
    >(
        accumulated: PartialPath<(P0, P1, P2)>,
        next: T.Type
    ) -> PartialPath<(P0, P1, P2, T)> {
        var accumulated = PartialPath<(P0, P1, P2, T)>(path: accumulated.path) { parameters in
            let previous = try accumulated.readParameters(&parameters)
            let next: T = try readParameter(from: &parameters)
            return (previous.0, previous.1, previous.2, next)
        }
        accumulated.path.append(.parameter(next))
        return accumulated
    }
}

extension HTTPEndpoint where InputBody == Void {
    public static func `get`(
        _ type: OutputBody.Type,
        @PathBuilder path: () -> PartialPath<Parameters>
    ) -> HTTPEndpoint<Void, OutputBody, Parameters> {
        let partial = path()
        
        return HTTPEndpoint(
            method: "GET",
            path: partial.path,
            readParameters: partial.readParameters
        )
    }
}
