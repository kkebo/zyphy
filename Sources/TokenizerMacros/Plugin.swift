#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct TokenizerMacrosPlugin {}

    extension TokenizerMacrosPlugin: CompilerPlugin {
        var providingMacros: [any Macro.Type] { [GoMacro.self] }
    }
#endif
