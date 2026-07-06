import HTTPTypes
import Wire
import WireOpenAPI

// M3.1 gate: the build plugin re-parses WireOpenAPI (via `_WireExports`), picks up
// `TransportKeys.handlers` and the `TransportComposable` conformance declaration, and emits
// `extension _WireGraph: TransportComposable`. `Wire.bootstrap()` returns the concrete graph,
// which therefore feeds `WireOpenAPI.apply` directly — confirming Wire Core needs no change
// for the `ServerTransport` surface (a `CollectedKey` → `[element]` member, the same
// non-associated-type emission shipped for Hummingbird routes).
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
