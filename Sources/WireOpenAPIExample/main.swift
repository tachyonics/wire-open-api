import HTTPTypes
import WireOpenAPI

// End-to-end: the build plugin collates the `@OpenAPIController` controller (its alias fans
// it into `TransportKeys.handlers`) and emits `extension _WireGraph: TransportComposable`.
// `Wire.bootstrap()` returns the concrete graph, which feeds `WireOpenAPI.apply` directly;
// `apply` calls each controller's generated witness, registering its handlers onto the
// transport.
let graph = try await Wire.bootstrap()

let transport = RecordingTransport()
try WireOpenAPI.apply(graph, to: transport)

let recorded = transport.registered.withLock { $0 }
precondition(recorded.count == 1, "expected 1 registered operation, got \(recorded.count)")
precondition(
    recorded[0].method == .get && recorded[0].path == "/ping",
    "unexpected registration: \(recorded)"
)

print("wire-open-api OK — TransportContributor collated into the graph and applied to a ServerTransport")
