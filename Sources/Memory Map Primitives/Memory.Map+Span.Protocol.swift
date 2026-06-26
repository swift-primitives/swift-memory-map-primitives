// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-memory-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Byte_Primitives
public import Span_Protocol_Primitives

// MARK: - Span (borrowing read surface over the user window)

/// The owned-conformer shape of `Span.Protocol`: the mapping computes a span
/// borrowing itself, over the USER window (the requested range), not the
/// page-aligned kernel region — `base + offsetDelta` for `userLength` bytes.
///
/// This is the modern read surface for zero-copy consumption of mapped files
/// (digests, parsers, searches): bounds-checked, lifetime-bound to the
/// envelope, no `withUnsafeBytes` ceremony.
extension Memory.Map: Span.`Protocol` {
    /// The element type exposed through the span: a single byte.
    public typealias Element = Byte

    /// A span of the mapping's user-visible bytes, borrowing the envelope.
    ///
    /// - Precondition: the mapping is live (not explicitly unmapped). Reading
    ///   bytes of a released mapping is a programmer error, not a recoverable
    ///   state.
    @inlinable
    public var span: Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            guard let region else {
                preconditionFailure("Memory.Map.span accessed after unmap")
            }
            let start = unsafe (region.base.pointer + Int(bitPattern: offsetDelta))
                .assumingMemoryBound(to: Byte.self)
            let s = unsafe Swift.Span(_unsafeStart: start, count: Int(bitPattern: userLength))
            return unsafe _overrideLifetime(s, borrowing: self)
        }
    }
}
