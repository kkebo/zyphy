import SwiftSyntax
import SwiftSyntaxMacros

public struct GoMacro {}

extension GoMacro: CodeItemMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        switch node.macro.text {
        case "go":
            var items = [CodeBlockItemSyntax]()
            var argList = node.argumentList
            loop: while let arg = argList.first, let label = arg.label {
                switch label.text {
                case "to":
                    precondition(argList.count == 1)
                    items += ["self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "reconsume":
                    precondition(argList.count == 2)
                    items += ["self.go(\(argList))", "return .continue"]
                    break loop
                case "emit":
                    if arg.expression.as(MemberAccessExprSyntax.self)?.name.text == "eof" {
                        precondition(argList.count == 1)
                        items += ["self.emitEOF()", "return .suspend"]
                        break loop
                    } else {
                        items += ["self.emit(\(arg.expression))"]
                        argList = argList.removingFirst()
                        while let arg = argList.first, arg.label == nil {
                            if arg.expression.as(MemberAccessExprSyntax.self)?.name.text == "eof" {
                                precondition(argList.count == 1)
                                items += ["self.emitEOF()", "return .suspend"]
                                break loop
                            } else {
                                items += ["self.emit(\(arg.expression))"]
                                argList = argList.removingFirst()
                            }
                        }
                    }
                case "error":
                    items += ["self.emitError(\(arg.expression))"]
                    argList = argList.removingFirst()
                    while let arg = argList.first, arg.label == nil {
                        items += ["self.emitError(\(arg.expression))"]
                        argList = argList.removingFirst()
                    }
                case let label:
                    preconditionFailure("not supported: \(String(describing: label))")
                }
            }
            return items
        case "goConsumeCharRef":
            return ["self.consumeCharRef()", "return .continue"]
        case let name:
            preconditionFailure("not supported: \(name)")
        }
    }
}
