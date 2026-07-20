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
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    /// A mapped memory region.
    ///
    /// Represents a region of memory that has been mapped into the process
    /// address space. Stores the base address and length of the mapping.
    ///
    /// Regions are created by platform-specific mapping functions.
    /// Use platform-specific `unmap` to release the region.
    ///
    /// ## Zero-Copy Byte Access
    ///
    /// `Region` is a plain `Copyable`, `Sendable` VALUE (base + length only):
    /// it carries no lifetime relationship to the mapping's actual liveness.
    /// It deliberately does **not** expose a `span` / `mutableSpan` accessor —
    /// a copy of `Region` taken from a live `Memory.Map` can freely outlive
    /// the mapping (the ~Copyable envelope), so any byte-view constructed
    /// from `Region` alone would carry zero liveness guarantee and could
    /// silently dangle after `munmap`. Zero-copy byte access is provided
    /// solely by the ~Copyable `Memory.Map` envelope itself (`Memory.Map.span`,
    /// `Span.Protocol` conformance in `Memory.Map+Span.Protocol.swift`), whose
    /// `@_lifetime(borrow self)` is anchored to the envelope that actually
    /// owns the mapping and traps if accessed after unmap.
    ///
    /// L2 syscall implementations (`msync`, `mprotect`, `munmap`, …) need
    /// only `base` and `length` — never a `Span` — so this restriction costs
    /// them nothing.
    ///
    /// ## Platform Implementation
    ///
    /// Region creation and unmapping are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`extension Memory.Map`)
    /// - Windows: `swift-windows-standard` (`extension Memory.Map`)
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
}
