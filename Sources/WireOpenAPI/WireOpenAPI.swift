import OpenAPIRuntime
import Wire

// WireOpenAPI — cross-runtime, app-scoped collation for OpenAPI. Controllers
// (`@OpenAPIController`) contribute into the handlers key; Wire emits a `TransportComposable`
// conformance on the generated graph (knowing nothing about OpenAPI or HTTP); `apply`
// registers the collated handlers onto a user-owned `ServerTransport` that stays *outside*
// the graph. Handlers-only — OpenAPI is a transport surface, not a runtime, so there is no
// services/lifecycle collation.
//
// This file holds the shared surface — the composable protocol, its graph conformance, and
// the `apply` facade; `TransportContributor.swift` holds the contributor protocol and its key.

/// The surface the facade consumes — the generated graph conforms to this. Named for the
/// surface, not the package (see `TransportKeys`).
public protocol TransportComposable {
    var handlers: [any TransportContributor] { get }
}

/// Tells Wire to emit `extension _WireGraph: TransportComposable`, mapping `handlers` to the
/// `TransportKeys.handlers` `CollectedKey` product.
public let wireTransportConformance = WireGraphConformanceV1(
    conformsTo: (any TransportComposable).self,
    members: [.init("handlers", from: TransportKeys.handlers)]
)

public enum WireOpenAPI {
    /// Register the graph's collated controllers onto a user-owned transport (a Hummingbird
    /// `Router`, a Vapor `Application`, a Lambda transport — any `ServerTransport`). Throws
    /// what the OpenAPI generator's `registerHandlers` throws.
    public static func apply(
        _ graph: some TransportComposable,
        to transport: some ServerTransport
    ) throws {
        for contributor in graph.handlers {
            try contributor.registerWireHandlers(on: transport)
        }
    }
}
