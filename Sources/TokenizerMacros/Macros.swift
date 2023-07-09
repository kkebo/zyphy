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
                case "createComment":
                    items += ["self.createComment(with: \(arg.expression))"]
                    argList = argList.removingFirst()
                case "appendComment":
                    items += ["self.currentComment.append(\(arg.expression))"]
                    argList = argList.removingFirst()
                case "clearComment":
                    precondition(argList.count == 1)
                    items += ["self.currentComment.removeAll()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "emitComment":
                    precondition(argList.count == 1)
                    items += ["self.emitComment()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "createStartTag":
                    items += ["self.createStartTag(with: \(arg.expression))"]
                    argList = argList.removingFirst()
                case "createEndTag":
                    items += ["self.createEndTag(with: \(arg.expression))"]
                    argList = argList.removingFirst()
                case "appendTagName":
                    items += ["self.currentTagName.append(\(arg.expression))"]
                    argList = argList.removingFirst()
                case "createAttr":
                    items += ["self.createAttr(with: \(arg.expression))"]
                    argList = argList.removingFirst()
                case "appendAttrName":
                    items += ["self.currentAttrName.append(\(arg.expression))"]
                    argList = argList.removingFirst()
                case "appendAttrValue":
                    items += ["self.currentAttrValue.append(\(arg.expression))"]
                    argList = argList.removingFirst()
                case "emitTag":
                    precondition(argList.count == 1)
                    items += ["self.go(to: \(arg.expression))", "self.emitTag()", "return .continue"]
                    break loop
                case "emitSelfClosingTag":
                    precondition(argList.count == 1)
                    items += ["self.go(to: \(arg.expression))", "self.emitSelfClosingTag()", "return .continue"]
                    break loop
                case "createDOCTYPE":
                    items += ["self.createDOCTYPE(with: \(arg.expression))"]
                    argList = argList.removingFirst()
                case "appendDOCTYPEName":
                    items += ["self.appendDOCTYPEName(\(arg.expression))"]
                    argList = argList.removingFirst()
                case "emitDOCTYPE":
                    precondition(argList.count == 1)
                    items += ["self.emitDOCTYPE()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case let label:
                    preconditionFailure("not supported: \(String(describing: label))")
                }
            }
            return items
        case "goEmitCommentAndEOF":
            return ["self.emitComment()", "self.emitEOF()", "return .suspend"]
        case "goEmitDOCTYPEAndEOF":
            return ["self.emitDOCTYPE()", "self.emitEOF()", "return .suspend"]
        case "goConsumeCharRef":
            return ["self.consumeCharRef()", "return .continue"]
        case let name:
            preconditionFailure("not supported: \(name)")
        }
    }
}
