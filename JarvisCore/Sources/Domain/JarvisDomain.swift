import Foundation

/// Domain layer for the Jarvis SDK
/// Contains business logic, use cases, and domain entities
public struct JarvisDomain {
    public static let version = "1.0.0"
}

// MARK: - Domain Entities

// Note: Core domain entities are defined in separate files
// This file contains the main domain module exports

// MARK: - Use Cases

/// Protocol for use cases
public protocol UseCase {
    associatedtype Input
    associatedtype Output

    func execute(_ input: Input) async throws -> Output
}

/// Example use case - concrete implementations will be added later
public struct ExampleUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = String

    public init() {}

    public func execute(_ input: Void) async throws -> String {
        return "Example"
    }
}