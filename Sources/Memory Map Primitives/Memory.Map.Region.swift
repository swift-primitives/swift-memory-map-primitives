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

public import Byte_Primitives

extension Memory.Map {
    /// A mapped memory region.
    ///
    /// Represents a region of memory that has been mapped into the process
    /// address space. Stores the base address and length of the mapping.
    ///
    /// Regions are created by platform-specific mapping functions.
    /// Use platform-specific `unmap` to release the region.
    ///
    /// ## Platform Implementation
    ///
    /// Region creation and unmapping are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`extension Memory.Map`)
    /// - Windows: `swift-windows-standard` (`extension Memory.Map`)
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    @safe
    public struct Region: Sendable {
        /// The base address of the mapped region.
        public let base: Memory.Address

        /// The length of the mapped region in bytes.
        public let length: Memory.Address.Count

        /// Creates a mapped region with the given address and length.
        @inlinable
        public init(base: Memory.Address, length: Memory.Address.Count) {
            self.base = base
            self.length = length
        }
    }
}

// MARK: - Buffer Access

extension Memory.Map.Region {
    /// The byte count of this region.
    @inlinable
    public var count: Int { Int(bitPattern: length) }

    /// A span of the region's bytes.
    @inlinable
    public var span: Span<Byte> {
        @_lifetime(borrow self) borrowing get {
            let pointer = unsafe base.pointer.assumingMemoryBound(to: Byte.self)
            let s = unsafe Span(_unsafeStart: pointer, count: count)
            return unsafe _overrideLifetime(s, borrowing: self)
        }
    }

    /// A mutable span of the region's bytes.
    @inlinable
    public var mutableSpan: MutableSpan<Byte> {
        @_lifetime(borrow self) borrowing get {
            let pointer = unsafe base.mutablePointer.assumingMemoryBound(to: Byte.self)
            let s = unsafe MutableSpan(_unsafeStart: pointer, count: count)
            return unsafe _overrideLifetime(s, borrowing: self)
        }
    }
}
