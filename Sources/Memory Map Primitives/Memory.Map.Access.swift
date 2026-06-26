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
    /// Access permissions for the mapped region.
    ///
    /// OptionSet-like structure that allows combining permissions:
    /// - `.read` — read-only access
    /// - `[.read, .write]` — read and write access
    ///
    /// ## Notes
    ///
    /// - `.write` requires `.read` on most platforms (POSIX constraint)
    /// - `.execute` is intentionally not included due to portability and security concerns
    public struct Access: OptionSet, Sendable, Hashable {
        /// The raw bitmask of access permissions.
        public let rawValue: Int

        /// Creates an access permission set from a raw bitmask.
        @inlinable
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Static Constants

extension Memory.Map.Access {
    /// Read permission.
    public static let read = Self(rawValue: 1 << 0)

    /// Write permission.
    ///
    /// - Important: On POSIX systems, `.write` implicitly requires `.read`.
    ///   Use `[.read, .write]` for clarity.
    public static let write = Self(rawValue: 1 << 1)
}

// MARK: - Allows Accessor

extension Memory.Map.Access {
    /// Nested accessor for permission queries.
    public var allows: Allows { Allows(access: self) }
}

// MARK: - Conversions live at L2 / L3
//
// `kernelProtection: Memory.Map.Protection` and `validate() throws(Memory.Error)`
// reference platform-specific constants (`Protection.read`, `.write`) and
// L3-extended error cases (`Memory.Error.access`) respectively, neither of
// which is in scope at L1. They live where their dependencies are visible.

// MARK: - Allows (nested accessor)

extension Memory.Map.Access {
    /// Nested accessor for permission queries.
    public struct Allows: Sendable {
        @usableFromInline
        let access: Memory.Map.Access

        @inlinable
        init(access: Memory.Map.Access) {
            self.access = access
        }

        /// Whether read access is permitted.
        @inlinable
        public var read: Bool { access.contains(.read) }

        /// Whether write access is permitted.
        @inlinable
        public var write: Bool { access.contains(.write) }
    }
}
