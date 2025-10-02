import Foundation

// MARK: - Result Extensions
public extension Result {
    /// Check if result is success
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Check if result is failure
    var isFailure: Bool {
        return !isSuccess
    }

    /// Get success value or nil
    var successValue: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Get failure error or nil
    var failureError: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    /// Map success value to another type
    func mapSuccess<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Map failure error to another type
    func mapFailure<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(transform(error))
        }
    }

    /// Flat map success value
    func flatMapSuccess<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Async Result Extensions
public extension Result {
    /// Async map success value
    func asyncMapSuccess<NewSuccess>(_ transform: @escaping (Success) async -> NewSuccess) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(await transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Async flat map success value
    func asyncFlatMapSuccess<NewSuccess>(_ transform: @escaping (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return await transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Result Builders
public extension Result {
    /// Create a Result from a throwing closure
    static func catching(_ body: () throws -> Success) -> Result<Success, Error> {
        do {
            return .success(try body())
        } catch {
            return .failure(error)
        }
    }

    /// Create a Result from an async throwing closure
    static func asyncCatching(_ body: () async throws -> Success) async -> Result<Success, Error> {
        do {
            return .success(try await body())
        } catch {
            return .failure(error)
        }
    }
}