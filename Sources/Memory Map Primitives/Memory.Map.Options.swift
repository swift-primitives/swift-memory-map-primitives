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
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Options, rhs: Options) -> Options {
            Options(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}
