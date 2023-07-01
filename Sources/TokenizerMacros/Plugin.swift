#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct MyPlugin {
        let providingMacros: [Macro.Type] = [
            GoMacro.self
        ]
    }

    extension MyPlugin: CompilerPlugin {}
#endif
