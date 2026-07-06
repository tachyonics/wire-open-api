// swift-tools-version: 6.3
import PackageDescription

// WireOpenAPI — a cross-runtime Wire adapter for swift-openapi-generator. It collates
// `@OpenAPIController` controllers into a handlers key, has Wire emit a `TransportComposable`
// conformance on the generated graph, and registers the collated handlers onto a user-owned
// `some ServerTransport` that stays outside the graph. Depends only on OpenAPIRuntime — no
// HTTP framework — so a wired controller mounts on Hummingbird, Vapor, or Lambda unchanged.
//
// Depends on pushed swift-wire main. `WireOpenAPIExample` is the runnable end-to-end
// validation (it applies swift-wire's build plugin). The `@OpenAPIController` macro is M3.2.
let package = Package(
    name: "wire-open-api",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "WireOpenAPI", targets: ["WireOpenAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/tachyonics/swift-wire.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WireOpenAPI",
            dependencies: [
                .product(name: "Wire", package: "swift-wire"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ]
        ),
        .executableTarget(
            name: "WireOpenAPIExample",
            dependencies: [
                "WireOpenAPI",
                .product(name: "Wire", package: "swift-wire"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
            plugins: [.plugin(name: "WireBuildPlugin", package: "swift-wire")]
        ),
    ]
)
