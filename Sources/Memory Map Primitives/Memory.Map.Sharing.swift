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
    /// Sharing semantics for the mapped region.
    public enum Sharing: Sendable, Equatable {
        /// Changes are visible to other mappings of the same file.
        ///
        /// Maps to:
        /// - POSIX: `MAP_SHARED`
        /// - Windows: Normal file mapping
        case shared

        /// Changes are private to this mapping (copy-on-write).
        ///
        /// Maps to:
        /// - POSIX: `MAP_PRIVATE`
        /// - Windows: `PAGE_WRITECOPY`
        case `private`
    }
}

// MARK: - Kernel Conversion lives at L2 / L3
//
// `kernelOptions: Memory.Map.Options` references platform-specific constants
// (`Options.shared`, `.private`) added at L2 (POSIX `MAP_SHARED` / `MAP_PRIVATE`,
// Windows equivalents). It lives where those constants are in scope.
