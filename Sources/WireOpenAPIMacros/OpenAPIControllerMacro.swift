import SwiftSyntax
import SwiftSyntaxMacros

/// `@OpenAPIController("path")` generates a `TransportContributor` conformance whose
/// `registerWireHandlers` witness calls the OpenAPI generator's `registerHandlers(on:)`.
/// A path becomes the transport's base `serverURL` (via `WireOpenAPI.serverURL(forBasePath:)`);
/// with no argument, handlers register at the spec's default server URL.
public struct OpenAPIControllerMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // The registration call: a base-path serverURL if a path was given, else the default.
        let registration: String
        if let path = firstStringLiteral(node.arguments) {
            registration =
                "try registerHandlers(on: transport, serverURL: WireOpenAPI.serverURL(forBasePath: \"\(path)\"))"
        } else {
            registration = "try registerHandlers(on: transport)"
        }

        let conformance: DeclSyntax =
            """
            extension \(type.trimmed): TransportContributor {
                func registerWireHandlers(on transport: any ServerTransport) throws {
                    \(raw: registration)
                }
            }
            """
        return [conformance.cast(ExtensionDeclSyntax.self)]
    }

    /// The first positional string-literal argument's value, or `nil` if the
    /// attribute has no arguments.
    private static func firstStringLiteral(_ arguments: AttributeSyntax.Arguments?) -> String? {
        guard case let .argumentList(list) = arguments, let first = list.first else { return nil }
        return first.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    }
}
