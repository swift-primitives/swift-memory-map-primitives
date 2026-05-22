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

extension Memory.Map {
    /// Memory protection flags controlling access to mapped pages.
    ///
    /// Specifies what operations are permitted on a memory mapping.
    ///
    /// ## Platform Implementation
    ///
    /// Platform-specific constants are in:
    /// - POSIX: `swift-iso-9945`
    /// - Windows: `swift-windows-standard`
    public struct Protection: Sendable, Equatable, Hashable, ExpressibleByArrayLiteral {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// No access permitted.
        public static let none = Protection(rawValue: 0)

        /// Combines multiple protection flags.
        @inlinable
        public static func | (lhs: Protection, rhs: Protection) -> Protection {
            Protection(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Checks if this contains another protection flag.
        @inlinable
        public func contains(_ other: Protection) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }

        /// Creates a protection value from an array of protection flags.
        @inlinable
        public init(arrayLiteral elements: Protection...) {
            self.rawValue = elements.reduce(0) { $0 | $1.rawValue }
        }
    }
}
