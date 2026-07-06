import HTTPTypes
import OpenAPIRuntime
import Synchronization
import Wire
import WireOpenAPI

// A framework-free `ServerTransport` that records the (method, path) of every registered
// operation — enough to prove the collation surface applies handlers to a real transport
// without pulling in an HTTP framework.
final class RecordingTransport: ServerTransport {
    let registered = Mutex<[(method: HTTPRequest.Method, path: String)]>([])

    func register(
        _ handler:
            @Sendable @escaping (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (
                HTTPResponse, HTTPBody?
            ),
        method: HTTPRequest.Method,
        path: String
    ) throws {
        registered.withLock { $0.append((method: method, path: path)) }
    }
}

// A hand-written transport contributor — no `@OpenAPIController` macro yet (that is M3.2).
// `@Singleton` makes it a binding; `@Contributes(to: TransportKeys.handlers)` fans it into
// the handlers collection the graph conformance exposes. Its witness registers one
// operation, standing in for the generated `registerHandlers`.
@Singleton
@Contributes(to: TransportKeys.handlers)
struct PingHandler: TransportContributor {
    @Inject init() {}

    func registerWireHandlers(on transport: any ServerTransport) throws {
        try transport.register(
            { _, _, _ in (HTTPResponse(status: .ok), nil) },
            method: .get,
            path: "/ping"
        )
    }
}
