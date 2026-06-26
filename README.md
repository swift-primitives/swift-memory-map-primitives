# Memory Map Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Memory-mapping (`mmap`) vocabulary for Swift — the `Memory.Map` namespace and its move-only RAII envelope, with the platform syscalls left to higher layers.

---

## Quick Start

`Memory.Map` is both a namespace for memory-mapping vocabulary and a move-only (`~Copyable`) envelope around one live mapping. This package holds the *shapes* — access permissions, sharing semantics, SIGBUS-safety posture, protection flags, advice, errors — so the same values travel unchanged from the platform package that performs the syscall (POSIX in [swift-iso-9945](https://github.com/swift-standards/swift-iso-9945), Windows in [swift-windows-standard](https://github.com/swift-standards/swift-windows-standard)) through every layer that consumes them.

```swift
import Memory_Map_Primitives

// Describe how a file should be mapped — the vocabulary an L2/L3 mapping
// API consumes when it calls mmap on your behalf.
let access: Memory.Map.Access = [.read, .write]
let sharing: Memory.Map.Sharing = .shared

// Choose a SIGBUS-safety posture: hold a shared file lock over the mapped
// range for the mapping's lifetime, or opt out for append-only snapshots.
let safety = Memory.Map.Safety.coordinated(.shared, scope: .mapped)

print(access.allows.write)   // true
```

`Memory.Map.Access` is an `OptionSet` whose `.allows` accessor answers permission queries (`access.allows.read`, `access.allows.write`). `Memory.Map.Safety` distinguishes `.coordinated(_:scope:)` — a held file lock that prevents truncation-induced SIGBUS when every writer respects the same discipline — from `.unchecked`, for append-only files, immutable snapshots, and WAL segments. `Memory.Map.Safety.default.read` and `.default.write` supply sensible defaults.

Because `Memory.Map` conforms to `Span.Protocol`, a live mapping exposes its user-visible bytes for zero-copy reads — bounds-checked, lifetime-bound to the envelope, with no `withUnsafeBytes` ceremony:

```swift
import Memory_Map_Primitives

// `map` is produced by a platform package; this package is the shared
// vocabulary it populates. Reading borrows the envelope for the call.
func firstByte(of map: borrowing Memory.Map) -> Byte? {
    let bytes = map.span
    return bytes.isEmpty ? nil : bytes[0]
}
```

The `span` is computed over the *user window* (the requested range), not the page-aligned kernel region the syscall actually returns — `base + offsetDelta` for `userLength` bytes.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-memory-map-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Memory Map Primitives", package: "swift-memory-map-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products. Sibling extraction of [swift-memory-primitives](https://github.com/swift-primitives/swift-memory-primitives): this package holds mapping vocabulary only — the syscall implementations live in platform packages as `extension Memory.Map`.

| Product | Target | Purpose |
|---------|--------|---------|
| `Memory Map Primitives` | `Sources/Memory Map Primitives/` | The `Memory.Map` namespace and its move-only RAII envelope: `Region`, `Protection`, `Sharing`, `Advice`, `Anonymous`, `File`, `Options`, `Access` (with `Allows`), `Safety` (with `Scope` and `Default`), `Error` (with `Validation`), plus the zero-copy `Span.Protocol` read surface. |
| `Memory Map Primitives Test Support` | `Tests/Support/` | Re-exports the main target and memory test support for downstream test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
