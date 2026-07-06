# wire-open-api

`WireOpenAPI` — a cross-runtime [swift-wire](https://github.com/tachyonics/swift-wire)
adapter for [swift-openapi-generator](https://github.com/apple/swift-openapi-generator).

It collates `@OpenAPIController` controllers (types conforming to the generated
`APIProtocol`) into a handlers key, has Wire emit a `TransportComposable` conformance on
the generated graph, and registers the collated handlers onto a user-owned
`some ServerTransport` that stays *outside* the graph. Because the target is
`ServerTransport` — and the package depends only on `OpenAPIRuntime`, no HTTP framework —
the same wired controller mounts on Hummingbird, Vapor, or Lambda unchanged.

Handlers-only: unlike a native-framework adapter, OpenAPI is a transport surface, not a
runtime, so services and lifecycle stay with the runtime's own adapter. The two coexist
on one graph.

See [swift-wire's WireOpenAPIDesign.md](https://github.com/tachyonics/swift-wire/blob/main/Documentation/Notes/WireOpenAPIDesign.md)
for the full design.

## Status

Under construction (M3).

- **M3.1** — the `ServerTransport` collation surface (`TransportContributor`,
  `TransportKeys.handlers`, `TransportComposable`, `WireOpenAPI.apply`) + a framework-free
  end-to-end example. **Current.**
- **M3.2** — the `@OpenAPIController` macro (a `@Contributes` alias whose witness calls
  `registerHandlers`; optional path → `serverURL`).
- **M3.3** — task-cluster migration.
- **M3.4** — cross-runtime proof (the same graph on a second transport).

Depends on pushed swift-wire `main`; validated on macOS and Linux (see CI).
