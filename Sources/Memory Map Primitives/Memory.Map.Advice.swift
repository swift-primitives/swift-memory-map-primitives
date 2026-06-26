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
    /// Memory access advice for madvise.
    ///
    /// ## Platform Implementation
    ///
    /// Advice constants are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`extension Memory.Map.Advice`)
    /// - Windows: `swift-windows-standard` (`extension Memory.Map.Advice`)
    public struct Advice: Sendable, Equatable, Hashable {
        /// The raw `madvise` advice value.
        public let rawValue: Int32

        /// Creates an advice value from a raw `madvise` constant.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
