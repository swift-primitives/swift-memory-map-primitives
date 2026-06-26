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

extension Memory.Map.Error {
    /// Validation failure reasons.
    public enum Validation: Sendable, Equatable, Hashable {
        /// Length must be greater than zero.
        case length
        /// Address alignment is invalid.
        case alignment
        /// Offset is invalid.
        case offset
    }
}

extension Memory.Map.Error.Validation: CustomStringConvertible {
    /// A human-readable description of the validation failure.
    public var description: Swift.String {
        switch self {
        case .length: return "length must be greater than zero"
        case .alignment: return "address alignment is invalid"
        case .offset: return "offset is invalid"
        }
    }
}
