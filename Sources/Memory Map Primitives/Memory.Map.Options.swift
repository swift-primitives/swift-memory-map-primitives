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
    /// Options controlling memory mapping behavior.
    ///
    /// Determines how the mapping interacts with the underlying file (if any)
    /// and other processes.
    ///
    /// ## Platform Implementation
    ///
    /// Platform-specific constants are in:
    /// - POSIX: `swift-iso-9945`
    /// - Windows: `swift-windows-standard`
    public struct Options: Sendable, Equatable, Hashable {
        /// The raw platform flag bits.
        public let rawValue: Int32

        /// Creates options from raw platform flag bits.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines two option sets by OR-ing their raw flag bits.
        @inlinable
        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}
