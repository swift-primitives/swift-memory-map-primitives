// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-memory-map-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-memory-map-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import Memory_Map_Primitives

extension Memory.Map.Region {
    @Suite struct Tests {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

// MARK: - Unit

extension Memory.Map.Region.Tests.Unit {
    /// F-001 (fable-448): `Region` is documented as "a pure Sendable value
    /// (base, length)" — this pins that shape down so a future PR can't
    /// silently re-add a zero-copy byte accessor without a test noticing the
    /// derived `count` no longer matching `length` 1:1.
    @Test func `region exposes only base, length, and derived count`() {
        let byteCount = 32
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: byteCount, alignment: 1)
        defer { unsafe buffer.deallocate() }

        let region = Memory.Map.Region(
            base: unsafe Memory.Address(buffer.baseAddress!),
            length: Memory.Address.Count(UInt(byteCount))
        )

        #expect(region.count == byteCount)
        #expect(Int(bitPattern: region.length) == byteCount)
    }
}

// MARK: - Edge Case

extension Memory.Map.Region.Tests.`Edge Case` {
    /// F-001 regression (fable-448): `Memory.Map.Region` previously exposed
    /// `@safe span` / `mutableSpan` computed properties. Because `Region` is
    /// `Copyable` + `Sendable`, a caller could copy it out of a live
    /// `Memory.Map` (via the public `region` accessor), let the owning
    /// `Memory.Map` deinitialize (running its unmap witness), and then still
    /// call `.span`/`.mutableSpan` on the escaped copy — constructing a
    /// `Span<Byte>` / `MutableSpan<Byte>` over already-released memory with
    /// no compiler diagnostic and no runtime liveness check whatsoever. That
    /// silently bypassed the `~Copyable` envelope's whole reason for being.
    ///
    /// The fix deletes `span`/`mutableSpan` from `Region` — zero-copy byte
    /// access now lives only on `Memory.Map` itself (`Memory.Map+Span.Protocol.swift`),
    /// whose `@_lifetime(borrow self)` is anchored to the envelope that
    /// actually owns the mapping and traps if accessed after unmap.
    ///
    /// A direct "the member is gone" assertion isn't expressible as a runtime
    /// `#expect` (Swift has no reflection over computed-property presence) —
    /// that half of the regression is evidenced in REPORT.md by the verbatim
    /// compiler diagnostic transition (`region.span` compiles pre-fix / fails
    /// with "has no member 'span'" post-fix, from the identical probe
    /// source). What IS expressible here, and stays green as a permanent
    /// regression guard, is the surviving half of the invariant: once the
    /// owning `Memory.Map` unmaps, a `Region` copied out beforehand is
    /// nothing more than inert `(base, length)` metadata — there is no
    /// operation on it, safe or otherwise, that reaches into the (possibly
    /// freed) backing storage.
    @Test func `region copied out before unmap outlives the map as inert metadata only`() throws {
        let byteCount = 16
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: byteCount, alignment: 1)
        unsafe buffer.initializeMemory(as: UInt8.self, repeating: 0)

        var unmapCount = 0
        var map: Memory.Map? = Memory.Map(
            region: Memory.Map.Region(
                base: unsafe Memory.Address(buffer.baseAddress!),
                length: Memory.Address.Count(UInt(byteCount))
            ),
            offsetDelta: Memory.Address.Count(0),
            userLength: Memory.Address.Count(UInt(byteCount)),
            access: [.read, .write],
            sharing: .private,
            safety: .unchecked,
            lockToken: nil,
            unmap: { _ in
                unsafe buffer.deallocate()
                unmapCount += 1
            }
        )

        // Copy `Region` out of the live map — this is exactly the escape
        // hatch F-001 flagged: `Region` is plain `Copyable`, so nothing
        // ties this copy's lifetime to `map`.
        let escapedRegion = map?.region

        // Drop the envelope: `Memory.Map.deinit` runs the unmap witness
        // exactly once (simulating munmap).
        map = nil
        #expect(unmapCount == 1)

        // The escaped copy survives (it's just two integers), but it now
        // offers nothing beyond that metadata — no `.span`, no
        // `.mutableSpan`, no way back into the freed buffer.
        let region = try #require(escapedRegion)
        #expect(region.count == byteCount)
        #expect(Int(bitPattern: region.length) == byteCount)
    }
}
