import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import WireOpenAPIMacros

final class OpenAPIControllerMacroTests: XCTestCase {
    private let macros: [String: any Macro.Type] = ["OpenAPIController": OpenAPIControllerMacro.self]

    func testDefaultServerURL() {
        assertMacroExpansion(
            """
            @OpenAPIController
            struct TaskController {}
            """,
            expandedSource: """
                struct TaskController {}

                extension TaskController: TransportContributor {
                    func registerWireHandlers(on transport: any ServerTransport) throws {
                        try registerHandlers(on: transport)
                    }
                }
                """,
            macros: macros
        )
    }

    func testPackageAccessWitness() {
        assertMacroExpansion(
            """
            @OpenAPIController
            package struct TaskController {}
            """,
            expandedSource: """
                package struct TaskController {}

                extension TaskController: TransportContributor {
                    package func registerWireHandlers(on transport: any ServerTransport) throws {
                        try registerHandlers(on: transport)
                    }
                }
                """,
            macros: macros
        )
    }

    func testPublicAccessWitness() {
        assertMacroExpansion(
            """
            @OpenAPIController
            public struct TaskController {}
            """,
            expandedSource: """
                public struct TaskController {}

                extension TaskController: TransportContributor {
                    public func registerWireHandlers(on transport: any ServerTransport) throws {
                        try registerHandlers(on: transport)
                    }
                }
                """,
            macros: macros
        )
    }

    func testBasePath() {
        assertMacroExpansion(
            """
            @OpenAPIController("/api/v1")
            struct TaskController {}
            """,
            expandedSource: """
                struct TaskController {}

                extension TaskController: TransportContributor {
                    func registerWireHandlers(on transport: any ServerTransport) throws {
                        try registerHandlers(on: transport, serverURL: WireOpenAPI.serverURL(forBasePath: "/api/v1"))
                    }
                }
                """,
            macros: macros
        )
    }
}
