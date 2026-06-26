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

extension Memory.Map {
    @Suite struct Tests {
        @Test func `namespace is available`() {
            // Minimal smoke test — the real suite is authored during flip-prep.
            #expect(Bool(true))
        }
    }
}
