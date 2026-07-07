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

        // The witness must be at least as accessible as the controller — it satisfies a public
        // protocol requirement, so a `public` or `package` controller needs a matching witness.
        let access = accessModifier(declaration.modifiers)

        let conformance: DeclSyntax =
            """
            extension \(type.trimmed): TransportContributor {
                \(raw: access)func registerWireHandlers(on transport: any ServerTransport) throws {
                    \(raw: registration)
                }
            }
            """
        return [conformance.cast(ExtensionDeclSyntax.self)]
    }

    /// The access-control modifier (with a trailing space) the witness must carry to match the
    /// controller's, or `""` for internal/private controllers where a default-access witness
    /// already satisfies the requirement. `open` maps to `public` — a struct witness can't be `open`.
    private static func accessModifier(_ modifiers: DeclModifierListSyntax) -> String {
        for modifier in modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.open): return "public "
            case .keyword(.package): return "package "
            default: continue
            }
        }
        return ""
    }

    /// The first positional string-literal argument's value, or `nil` if the
    /// attribute has no arguments.
    private static func firstStringLiteral(_ arguments: AttributeSyntax.Arguments?) -> String? {
        guard case let .argumentList(list) = arguments, let first = list.first else { return nil }
        return first.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    }
}
