#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct MyPlugin {
        let providingMacros: [any Macro.Type] = [
            GoMacro.self
        ]
    }

    extension MyPlugin: CompilerPlugin {}
#endif
