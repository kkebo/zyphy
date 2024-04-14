import Tokenizer

public struct TreeConstructor {
    private var mode: InsertionMode

    public init() {
        self.mode = .initial
    }
}

extension TreeConstructor: TokenSink {
    mutating func process(_ token: consuming Token) {
        switch self.mode {
        case .initial:
            switch token {
            case .char("\t"), .char("\n"), .char("\u{000C}"), .char("\r"), .char(" "): break
            case .comment(_): fatalError("not implemented")
            case .doctype(_): fatalError("not implemented")
            case _: fatalError("not implemented")
            }
        case .beforeHTML:
            fatalError("not implemented")
        case .beforeHead:
            fatalError("not implemented")
        case .inHead:
            fatalError("not implemented")
        case .inHeadNoscript:
            fatalError("not implemented")
        case .afterHead:
            fatalError("not implemented")
        case .inBody:
            fatalError("not implemented")
        case .text:
            fatalError("not implemented")
        case .inTable:
            fatalError("not implemented")
        case .inTableText:
            fatalError("not implemented")
        case .inCaption:
            fatalError("not implemented")
        case .inColumnGroup:
            fatalError("not implemented")
        case .inTableBody:
            fatalError("not implemented")
        case .inRow:
            fatalError("not implemented")
        case .inCell:
            fatalError("not implemented")
        case .inSelect:
            fatalError("not implemented")
        case .inSelectInTable:
            fatalError("not implemented")
        case .inTemplate:
            fatalError("not implemented")
        case .afterBody:
            fatalError("not implemented")
        case .inFrameset:
            fatalError("not implemented")
        case .afterFrameset:
            fatalError("not implemented")
        case .afterAfterBody:
            fatalError("not implemented")
        case .afterAfterFrameset:
            fatalError("not implemented")
        }
    }
}
