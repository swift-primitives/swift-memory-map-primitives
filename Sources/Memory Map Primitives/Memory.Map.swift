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

extension Memory {
    /// A move-only memory-mapped file region.
    ///
    /// Acts as both the namespace for memory-mapping vocabulary
    /// (`Memory.Map.Region`, `Memory.Map.Error`, `Memory.Map.Protection`,
    /// `Memory.Map.Anonymous`, `Memory.Map.File`, etc.) and the concrete
    /// RAII wrapper for an active mapping.
    ///
    /// ## Lifetime
    /// - `~Copyable` (move-only)
    /// - `unmap()` (or equivalent L3 ergonomic) explicitly releases
    /// - `deinit` releases as a backstop via the witness closure
    ///
    /// ## Safety Invariant
    ///
    /// `~Copyable` prevents aliasing. The envelope is deliberately **not**
    /// `Sendable`: the unmap witness is a stored closure whose captures the
    /// type cannot see, so cross-isolation transfer is region-checked per
    /// send — boundary APIs take `consuming sending Memory.Map`. Mapping bytes
    /// are raw memory: concurrent writes to the same offset are data races the
    /// caller must synchronize.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`extension Memory.Map`)
    /// - Windows: `swift-windows-standard` (`extension Memory.Map`)
    public struct Map: ~Copyable {
        /// The underlying kernel memory region.
        @_spi(MemoryInternal)
        public var _region: Memory.Map.Region?

        /// Delta between user-requested offset and mapping base
        /// (always non-negative; alignment rounds down).
        @_spi(MemoryInternal)
        public let _offsetDelta: Memory.Address.Count

        /// The user-visible length (requested length).
        @_spi(MemoryInternal)
        public let _userLength: Memory.Address.Count

        /// The access mode for this mapping.
        ///
        /// Reflects the current protection. May change via L3-provided `protect`.
        @_spi(MemoryInternal)
        public var access: Access

        /// The sharing mode for this mapping.
        public let sharing: Sharing

        /// The safety mode for this mapping.
        public let safety: Safety

        /// Lock token for `.coordinated` safety mode (released with the mapping).
        @_spi(MemoryInternal)
        public var _lockToken: Memory.Lock.Token?

        /// Platform-syscall cleanup witness (injected at construction).
        ///
        /// A plain closure, not `@Sendable`: the witness runs wherever the last
        /// owner drops the envelope, and region isolation checks each transfer
        /// at the send site — a witness capturing isolated state is rejected
        /// there, not laundered through a type-level promise.
        @_spi(MemoryInternal)
        public let _unmap: (Memory.Map.Region) -> Void

        /// Creates a mapping with the given fields and unmap witness.
        ///
        /// L3 packages construct values of this type. The `unmap` closure
        /// is invoked exactly once on `deinit` if a region is still owned.
        public init(
            region: Memory.Map.Region?,
            offsetDelta: Memory.Address.Count,
            userLength: Memory.Address.Count,
            access: Access,
            sharing: Sharing,
            safety: Safety,
            lockToken: consuming Memory.Lock.Token?,
            unmap: @escaping (Memory.Map.Region) -> Void
        ) {
            self._region = region
            self._offsetDelta = offsetDelta
            self._userLength = userLength
            self.access = access
            self.sharing = sharing
            self.safety = safety
            self._lockToken = lockToken
            self._unmap = unmap
        }

        deinit {
            guard let region = _region else { return }
            _unmap(region)
        }
    }
}

// MARK: - Field Accessors

extension Memory.Map {
    /// The underlying kernel memory region (nil after explicit unmap).
    public var region: Memory.Map.Region? { _region }

    /// Delta between user-requested offset and mapping base.
    public var offsetDelta: Memory.Address.Count { _offsetDelta }

    /// The user-visible length (requested length).
    public var userLength: Memory.Address.Count { _userLength }
}
