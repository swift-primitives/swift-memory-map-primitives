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
        /// The raw platform protection bits.
        public let rawValue: Int32

        /// Creates a protection value from raw platform protection bits.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// No access permitted.
        public static let none = Self(rawValue: 0)

        /// Combines two protection values by OR-ing their raw bits.
        @inlinable
        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Returns whether this protection value contains every bit of another.
        @inlinable
        public func contains(_ other: Self) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }

        /// Creates a protection value by OR-ing an array of protection flags.
        @inlinable
        public init(arrayLiteral elements: Self...) {
            self.rawValue = elements.reduce(0) { $0 | $1.rawValue }
        }
    }
}
