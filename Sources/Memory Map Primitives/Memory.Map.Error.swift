// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-memory-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-memory-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Error_Primitives

extension Memory.Map {
    /// Errors from mmap operations.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Failed to map memory.
        case map(Error_Primitives.Error.Code)

        /// Failed to unmap memory.
        case unmap(Error_Primitives.Error.Code)

        /// Failed to sync memory to disk.
        case sync(Error_Primitives.Error.Code)

        /// Failed to change memory protection.
        case protect(Error_Primitives.Error.Code)

        /// Out of memory (`ENOMEM`).
        case exhausted

        /// Invalid argument.
        case invalid(Validation)
    }
}

extension Memory.Map.Error: CustomStringConvertible {
    /// A human-readable description of the mapping error.
    public var description: Swift.String {
        switch self {
        case .map(let code):
            return "mmap failed (\(code))"

        case .unmap(let code):
            return "munmap failed (\(code))"

        case .sync(let code):
            return "msync failed (\(code))"

        case .protect(let code):
            return "mprotect failed (\(code))"

        case .exhausted:
            return "out of memory"

        case .invalid(let validation):
            return "invalid argument: \(validation)"
        }
    }
}
