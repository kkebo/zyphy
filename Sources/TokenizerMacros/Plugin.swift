#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct MyPlugin: CompilerPlugin {
        let providingMacros: [any Macro.Type] = [
            GoMacro.self
        ]
    }
#endif
