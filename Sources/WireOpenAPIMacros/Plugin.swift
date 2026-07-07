import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct WireOpenAPIMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [OpenAPIControllerMacro.self]
}
