import SwiftSyntax
import SwiftSyntaxMacros

struct GoMacro {}

extension GoMacro: CodeItemMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> [CodeBlockItemSyntax] {
        switch node.macroName.text {
        case "go":
            var items = [CodeBlockItemSyntax]()
            var argList = node.arguments
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
                    if arg.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text == "eof" {
                        precondition(argList.count == 1)
                        items += ["self.emitEOF()", "return .suspend"]
                        break loop
                    } else {
                        items += ["self.emit(\(arg.expression))"]
                        argList = .init(argList.dropFirst())
                        while let arg = argList.first, arg.label == nil {
                            if arg.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text == "eof" {
                                precondition(argList.count == 1)
                                items += ["self.emitEOF()", "return .suspend"]
                                break loop
                            } else {
                                items += ["self.emit(\(arg.expression))"]
                                argList = .init(argList.dropFirst())
                            }
                        }
                    }
                case "error":
                    items += ["self.emitError(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                    while let arg = argList.first, arg.label == nil {
                        items += ["self.emitError(\(arg.expression))"]
                        argList = .init(argList.dropFirst())
                    }
                case "createComment":
                    items += ["self.createComment(with: \(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendComment":
                    items += ["self.appendComment(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
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
                    argList = .init(argList.dropFirst())
                case "createEndTag":
                    items += ["self.createEndTag(with: \(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendTagName":
                    items += ["self.currentTagName.append(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "createAttr":
                    items += ["self.createAttr(with: \(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendAttrName":
                    items += ["self.currentAttrName.append(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendAttrValue":
                    items += ["self.currentAttrValue.append(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "emitTag":
                    precondition(argList.count == 1)
                    items += ["self.go(to: \(arg.expression))", "self.emitTag()", "return .continue"]
                    break loop
                case "emitSelfClosingTag":
                    precondition(argList.count == 1)
                    items += ["self.go(to: \(arg.expression))", "self.emitTag(selfClosing: true)", "return .continue"]
                    break loop
                case "createDOCTYPE":
                    items += ["self.createDOCTYPE(with: \(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendDOCTYPEName":
                    items += ["self.appendDOCTYPEName(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendPublicID":
                    items += ["self.appendPublicID(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "clearPublicID":
                    precondition(argList.count == 1)
                    items += ["self.clearPublicID()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "appendSystemID":
                    items += ["self.appendSystemID(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "clearSystemID":
                    precondition(argList.count == 1)
                    items += ["self.clearSystemID()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "forceQuirks":
                    precondition(argList.count == 1)
                    items += ["self.forceQuirks()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "emitDOCTYPE":
                    precondition(argList.count == 1)
                    items += ["self.emitDOCTYPE()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "emitForceQuirksDOCTYPE":
                    precondition(argList.count == 1)
                    items += ["self.forceQuirks()", "self.emitDOCTYPE()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "emitNewForceQuirksDOCTYPE":
                    precondition(argList.count == 1)
                    items += ["self.createDOCTYPE()", "self.forceQuirks()", "self.emitDOCTYPE()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "createTemp":
                    items += ["self.createTempBuffer(with: \(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "appendTemp":
                    items += ["self.tempBuffer.append(\(arg.expression))"]
                    argList = .init(argList.dropFirst())
                case "clearTemp":
                    items += ["self.tempBuffer.removeAll()", "self.go(to: \(arg.expression))", "return .continue"]
                    break loop
                case "emitTempAndReconsume":
                    precondition(argList.count == 2)
                    var arg1 = arg
                    arg1.label = "reconsume"
                    guard let arg2 = argList.dropFirst().first else { preconditionFailure() }
                    items += ["self.emitTempBuffer()", "self.go(\(arg1)\(arg2))", "return .continue"]
                    break loop
                case "emitTempAndEmit":
                    if arg.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text == "eof" {
                        precondition(argList.count == 1)
                        items += ["self.emitTempBuffer()", "self.emitEOF()", "return .suspend"]
                        break loop
                    } else {
                        preconditionFailure("not supported")
                    }
                case let label:
                    preconditionFailure("not supported: \(String(describing: label))")
                }
            }
            return items
        case "goEmitCommentAndEOF":
            return ["self.emitComment()", "self.emitEOF()", "return .suspend"]
        case "goEmitDOCTYPEAndEOF":
            return ["self.emitDOCTYPE()", "self.emitEOF()", "return .suspend"]
        case "goEmitForceQuirksDOCTYPEAndEOF":
            return ["self.forceQuirks()", "self.emitDOCTYPE()", "self.emitEOF()", "return .suspend"]
        case "goEmitNewForceQuirksDOCTYPEAndEOF":
            return ["self.createDOCTYPE()", "self.forceQuirks()", "self.emitDOCTYPE()", "self.emitEOF()", "return .suspend"]
        case "goConsumeCharRef":
            return ["self.consumeCharRef()", "return .continue"]
        case let name:
            preconditionFailure("not supported: \(name)")
        }
    }
}
