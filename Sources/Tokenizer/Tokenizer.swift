public import Collections

@freestanding(codeItem) private macro go(emit: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token...) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token..., to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token..., reconsume: Character, in: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token..., clearTemp: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token..., emitTempAndReconsume: Character, in: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emit: Token..., emitTempAndEmit: Token) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createTemp: Character, emit: Token..., to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendTemp: Character, emit: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createComment: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createComment: String, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendComment: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendComment: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendComment: String, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., clearComment: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitComment: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createStartTag: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createEndTag: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createEndTag: Character, appendTemp: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendTagName: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendTagName: Character, appendTemp: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createAttr: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendAttrName: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendAttrValue: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitTag: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitSelfClosingTag: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., createDOCTYPE: Character, to: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendDOCTYPEName: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendPublicID: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., clearPublicID: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., appendSystemID: Character) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., clearSystemID: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., forceQuirks: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitDOCTYPE: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitForceQuirksDOCTYPE: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro go(error: ParseError..., emitNewForceQuirksDOCTYPE: State) = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro goEmitCommentAndEOF() = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro goEmitDOCTYPEAndEOF() = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro goEmitForceQuirksDOCTYPEAndEOF() = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro goEmitNewForceQuirksDOCTYPEAndEOF() = #externalMacro(module: "TokenizerMacros", type: "GoMacro")
@freestanding(codeItem) private macro goConsumeCharRef() = #externalMacro(module: "TokenizerMacros", type: "GoMacro")

public struct Tokenizer<Sink: TokenSink>: ~Copyable {
    public var sink: Sink
    package var state: State
    private var reconsumeChar: Optional<Character>
    private var tempBuffer: String
    private var currentComment: String
    private var currentTagName: String
    private var currentTagKind: TagKind
    private var currentAttrName: String
    private var currentAttrValue: String
    private var currentAttrs: [String: String]
    private var lastStartTagName: Optional<String>
    private var currentDOCTYPE: DOCTYPE
    private var charRefTokenizer: Optional<CharRefTokenizer>

    public init(sink: consuming Sink) {
        self.sink = sink
        self.state = .data
        self.reconsumeChar = nil
        self.tempBuffer = ""
        self.currentComment = ""
        self.currentTagName = ""
        self.currentTagKind = .start
        self.currentAttrName = ""
        self.currentAttrValue = ""
        self.currentAttrs = [:]
        self.lastStartTagName = nil
        self.currentDOCTYPE = .init()
        self.charRefTokenizer = nil
    }

    public mutating func tokenize(_ input: inout Deque<Character>) {
        loop: repeat {
            switch self.step(&input) {
            case .continue: break
            case .suspend: break loop
            }
        } while true
    }

    // swift-format-ignore
    private mutating func step(_ input: inout Deque<Character>) -> ProcessResult {
        if var charRefTokenizer {
            if let scalars = charRefTokenizer.tokenize(tokenizer: &self, input: &input) {
                self.processCharRef(scalars)
            }
            self.charRefTokenizer = nil
        }

        switch self.state {
        case .data: repeat {
            switch self.getChar(from: &input) {
            case "&": #goConsumeCharRef
            case "<": #go(to: .tagOpen)
            case "\0": #go(error: .unexpectedNull, emit: "\0")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .rcdata: repeat {
            switch self.getChar(from: &input) {
            case "&": #goConsumeCharRef
            case "<": #go(to: .rcdataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .rawtext: repeat {
            switch self.getChar(from: &input) {
            case "<": #go(to: .rawtextLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .scriptData: repeat {
            switch self.getChar(from: &input) {
            case "<": #go(to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .plaintext: repeat {
            switch self.getChar(from: &input) {
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .tagOpen: repeat {
            switch self.getChar(from: &input) {
            case "!": #go(to: .markupDeclarationOpen)
            case "/": #go(to: .endTagOpen)
            case "?": #go(error: .unexpectedQuestionMark, createComment: "?", to: .bogusComment)
            case nil: #go(error: .eofBeforeTagName, emit: "<", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createStartTag: cl, to: .tagName)
                case nil: #go(error: .invalidFirstChar, emit: "<", reconsume: c, in: .data)
                }
            }
        } while true
        case .endTagOpen: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(error: .missingEndTagName, to: .data)
            case "\0": #go(error: .invalidFirstChar, .unexpectedNull, createComment: "\u{FFFD}", to: .bogusComment)
            case nil: #go(error: .eofBeforeTagName, emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, to: .tagName)
                case nil: #go(error: .invalidFirstChar, createComment: c, to: .bogusComment)
                }
            }
        } while true
        case .tagName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "\0": #go(error: .unexpectedNull, appendTagName: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(appendTagName: lowerASCII(c))
            }
        } while true
        case .rcdataLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .rcdataEndTagOpen)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", reconsume: c, in: .rcdata)
            }
        } while true
        case .rcdataEndTagOpen: repeat {
            switch self.getChar(from: &input) {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .rcdataEndTagName)
                case nil: #go(emit: "<", "/", reconsume: c, in: .rcdata)
                }
            case nil: #go(emit: "<", "/", .eof)
            }
        } while true
        case .rcdataEndTagName: repeat {
            let c = self.getChar(from: &input)
            if self.currentTagKind == .end && self.currentTagName == self.lastStartTagName {
                switch c {
                case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
                case "/": #go(to: .selfClosingStartTag)
                case ">": #go(emitTag: .data)
                case _: break
                }
            }
            switch c {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTagName: cl, appendTemp: c)
                case nil: #go(emit: "<", "/", emitTempAndReconsume: c, in: .rcdata)
                }
            case nil: #go(emit: "<", "/", emitTempAndEmit: .eof)
            }
        } while true
        case .rawtextLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .rawtextEndTagOpen)
            case "<": #go(emit: "<", to: .rawtextLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .rawtext)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", .char(c), to: .rawtext)
            }
        } while true
        case .rawtextEndTagOpen: repeat {
            switch self.getChar(from: &input) {
            case "<": #go(emit: "<", "/", to: .rawtextLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "/", "\u{FFFD}", to: .rawtext)
            case nil: #go(emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .rawtextEndTagName)
                case nil: #go(emit: "<", "/", .char(c), to: .rawtext)
                }
            }
        } while true
        case .rawtextEndTagName: repeat {
            let c = self.getChar(from: &input)
            if self.currentTagKind == .end && self.currentTagName == self.lastStartTagName {
                switch c {
                case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
                case "/": #go(to: .selfClosingStartTag)
                case ">": #go(emitTag: .data)
                case _: break
                }
            }
            switch c {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTagName: cl, appendTemp: c)
                case nil: #go(emit: "<", "/", emitTempAndReconsume: c, in: .rawtext)
                }
            case nil: #go(emit: "<", "/", emitTempAndEmit: .eof)
            }
        } while true
        case .scriptDataLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .scriptDataEndTagOpen)
            case "!": #go(emit: "<", "!", to: .scriptDataEscapeStart)
            case "<": #go(emit: "<", to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .scriptData)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", .char(c), to: .scriptData)
            }
        } while true
        case .scriptDataEndTagOpen: repeat {
            switch self.getChar(from: &input) {
            case "<": #go(emit: "<", "/", to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", ",", "\u{FFFD}", to: .scriptData)
            case nil: #go(emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .scriptDataEndTagName)
                case nil: #go(emit: "<", "/", .char(c), to: .scriptData)
                }
            }
        } while true
        case .scriptDataEndTagName: repeat {
            let c = self.getChar(from: &input)
            if self.currentTagKind == .end && self.currentTagName == self.lastStartTagName {
                switch c {
                case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
                case "/": #go(to: .selfClosingStartTag)
                case ">": #go(emitTag: .data)
                case _: break
                }
            }
            switch c {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTagName: cl, appendTemp: c)
                case nil: #go(emit: "<", "/", emitTempAndReconsume: c, in: .scriptData)
                }
            case nil: #go(emit: "<", "/", emitTempAndEmit: .eof)
            }
        } while true
        case .scriptDataEscapeStart: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapeStartDash)
            case "<": #go(to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .scriptDataEscapeStartDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapedDashDash)
            case "<": #go(to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .scriptDataEscaped: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapedDash)
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .scriptDataEscapedDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapedDashDash)
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: .char(c), to: .scriptDataEscaped)
            }
        } while true
        case .scriptDataEscapedDashDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-")
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case ">": #go(emit: ">", to: .scriptData)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: .char(c), to: .scriptDataEscaped)
            }
        } while true
        case .scriptDataEscapedLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .scriptDataEscapedEndTagOpen)
            case "-": #go(emit: "<", "-", to: .scriptDataEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: "<", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createTemp: cl, emit: "<", .char(c), to: .scriptDataDoubleEscapeStart)
                case nil: #go(emit: "<", .char(c), to: .scriptDataEscaped)
                }
            }
        } while true
        case .scriptDataEscapedEndTagOpen: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "<", "/", "-", to: .scriptDataEscapedDash)
            case "<": #go(emit: "<", "/", to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "/", "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .scriptDataEscapedEndTagName)
                case nil: #go(emit: "<", "/", .char(c), to: .scriptDataEscaped)
                }
            }
        } while true
        case .scriptDataEscapedEndTagName: repeat {
            let c = self.getChar(from: &input)
            if self.currentTagKind == .end && self.currentTagName == self.lastStartTagName {
                switch c {
                case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
                case "/": #go(to: .selfClosingStartTag)
                case ">": #go(emitTag: .data)
                case _: break
                }
            }
            switch c {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTagName: cl, appendTemp: c)
                case nil: #go(emit: "<", "/", emitTempAndReconsume: c, in: .scriptDataEscaped)
                }
            case nil: #go(emit: "<", "/", emitTempAndEmit: .eof)
            }
        } while true
        case .scriptDataDoubleEscapeStart: repeat {
            guard let c = self.getChar(from: &input) else { #go(error: .eofInScriptComment, emit: .eof) }
            switch c {
            case "\t", "\n", "\u{0C}", " ", "/", ">":
                if self.tempBuffer == "script" {
                    #go(emit: .char(c), to: .scriptDataDoubleEscaped)
                } else {
                    #go(emit: .char(c), to: .scriptDataEscaped)
                }
            case "-": #go(emit: "-", to: .scriptDataEscapedDash)
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case let c:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTemp: cl, emit: c)
                case nil: #go(emit: .char(c), to: .scriptDataEscaped)
                }
            }
        } while true
        case .scriptDataDoubleEscaped: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .scriptDataDoubleEscapedDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDashDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: .char(c), to: .scriptDataDoubleEscaped)
            }
        } while true
        case .scriptDataDoubleEscapedDashDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-")
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case ">": #go(emit: ">", to: .scriptData)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: .char(c), to: .scriptDataDoubleEscaped)
            }
        } while true
        case .scriptDataDoubleEscapedLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "/": #go(emit: "/", clearTemp: .scriptDataDoubleEscapeEnd)
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: .char(c), to: .scriptDataDoubleEscaped)
            }
        } while true
        case .scriptDataDoubleEscapeEnd: repeat {
            guard let c = self.getChar(from: &input) else { #go(error: .eofInScriptComment, emit: .eof) }
            switch c {
            case "\t", "\n", "\u{0C}", " ", "/", ">":
                if self.tempBuffer == "script" {
                    #go(emit: .char(c), to: .scriptDataEscaped)
                } else {
                    #go(emit: .char(c), to: .scriptDataDoubleEscaped)
                }
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case let c:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTemp: cl, emit: c)
                case nil: #go(emit: .char(c), to: .scriptDataDoubleEscaped)
                }
            }
        } while true
        case .beforeAttributeName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "=": #go(error: .unexpectedEqualsSign, createAttr: "=", to: .attributeName)
            case "\0": #go(error: .unexpectedNull, createAttr: "\u{FFFD}", to: .attributeName)
            case "\"": #go(error: .unexpectedCharInAttrName, createAttr: "\"", to: .attributeName)
            case "'": #go(error: .unexpectedCharInAttrName, createAttr: "'", to: .attributeName)
            case "<": #go(error: .unexpectedCharInAttrName, createAttr: "<", to: .attributeName)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(createAttr: lowerASCII(c), to: .attributeName)
            }
        } while true
        case .attributeName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .afterAttributeName)
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "=": #go(to: .beforeAttributeValue)
            case "\0": #go(error: .unexpectedNull, appendAttrName: "\u{FFFD}")
            case "\"": #go(error: .unexpectedCharInAttrName, appendAttrName: "\"")
            case "'": #go(error: .unexpectedCharInAttrName, appendAttrName: "'")
            case "<": #go(error: .unexpectedCharInAttrName, appendAttrName: "<")
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(appendAttrName: lowerASCII(c))
            }
        } while true
        case .afterAttributeName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "=": #go(to: .beforeAttributeValue)
            case "\0": #go(error: .unexpectedNull, createAttr: "\u{FFFD}", to: .attributeName)
            case "\"": #go(error: .unexpectedCharInAttrName, createAttr: "\"", to: .attributeName)
            case "'": #go(error: .unexpectedCharInAttrName, createAttr: "'", to: .attributeName)
            case "<": #go(error: .unexpectedCharInAttrName, createAttr: "<", to: .attributeName)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(createAttr: lowerASCII(c), to: .attributeName)
            }
        } while true
        case .beforeAttributeValue: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\"": #go(to: .attributeValueDoubleQuoted)
            case "'": #go(to: .attributeValueSingleQuoted)
            case ">": #go(error: .missingAttrValue, emitTag: .data)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(reconsume: c, in: .attributeValueUnquoted)
            }
        } while true
        case .attributeValueDoubleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "\"": #go(to: .afterAttributeValueQuoted)
            case "&": #goConsumeCharRef
            case "\0": #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(appendAttrValue: c)
            }
        } while true
        case .attributeValueSingleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "'": #go(to: .afterAttributeValueQuoted)
            case "&": #goConsumeCharRef
            case "\0": #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(appendAttrValue: c)
            }
        } while true
        case .attributeValueUnquoted: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
            case "&": #goConsumeCharRef
            case ">": #go(emitTag: .data)
            case "\0": #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case "\"": #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
            case "'": #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "'")
            case "<": #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "<")
            case "=": #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "=")
            case "`": #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "`")
            case let c?: #go(appendAttrValue: c)
            }
        } while true
        case .afterAttributeValueQuoted: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "=": #go(error: .missingSpaceBetweenAttrs, .unexpectedEqualsSign, createAttr: "=", to: .attributeName)
            case "\0": #go(error: .missingSpaceBetweenAttrs, .unexpectedNull, createAttr: "\u{FFFD}", to: .attributeName)
            case "\"": #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "\"", to: .attributeName)
            case "'": #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "'", to: .attributeName)
            case "<": #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "<", to: .attributeName)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(error: .missingSpaceBetweenAttrs, createAttr: lowerASCII(c), to: .attributeName)
            }
        } while true
        case .selfClosingStartTag: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitSelfClosingTag: .data)
            case "\t", "\n", "\u{0C}", " ": #go(error: .unexpectedSolidus, to: .beforeAttributeName)
            case "/": #go(error: .unexpectedSolidus, to: .selfClosingStartTag)
            case "=": #go(error: .unexpectedSolidus, .unexpectedEqualsSign, createAttr: "=", to: .attributeName)
            case "\0": #go(error: .unexpectedSolidus, .unexpectedNull, createAttr: "\u{FFFD}", to: .attributeName)
            case "\"": #go(error: .unexpectedSolidus, .unexpectedCharInAttrName, createAttr: "\"", to: .attributeName)
            case "'": #go(error: .unexpectedSolidus, .unexpectedCharInAttrName, createAttr: "'", to: .attributeName)
            case "<": #go(error: .unexpectedSolidus, .unexpectedCharInAttrName, createAttr: "<", to: .attributeName)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(error: .unexpectedSolidus, createAttr: lowerASCII(c), to: .attributeName)
            }
        } while true
        case .bogusComment: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitComment: .data)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}")
            case nil: #goEmitCommentAndEOF
            case let c?: #go(appendComment: c)
            }
        } while true
        case .markupDeclarationOpen: repeat {
            if self.startsExact(&input, with: "--") == true {
                #go(clearComment: .commentStart)
            } else if self.starts(&input, with: "doctype") == true {
                #go(to: .doctype)
            } else if self.startsExact(&input, with: "[CDATA[") == true {
                if false {
                    // TODO: If there is an adjusted current node and it is not an element in the HTML namespace, then switch to the CDATA section state.
                    #go(to: .cdataSection)
                } else {
                    #go(error: .cdataInHTML, createComment: "[CDATA[", to: .bogusComment)
                }
            } else {
                #go(error: .incorrectlyOpenedComment, clearComment: .bogusComment)
            }
        } while true
        case .commentStart: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentStartDash)
            case ">": #go(error: .abruptClosingComment, emitComment: .data)
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
        case .commentStartDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentEnd)
            case ">": #go(error: .abruptClosingComment, emitComment: .data)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
        case .comment: repeat {
            switch self.getChar(from: &input) {
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "-": #go(to: .commentEndDash)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}")
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c)
            }
        } while true
        case .commentLessThanSign: repeat {
            switch self.getChar(from: &input) {
            case "!": #go(appendComment: "!", to: .commentLessThanSignBang)
            case "<": #go(appendComment: "<")
            case "-": #go(to: .commentEndDash)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
        case .commentLessThanSignBang: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentLessThanSignBangDash)
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
        case .commentLessThanSignBangDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentLessThanSignBangDashDash)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
        case .commentLessThanSignBangDashDash: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitComment: .data)
            case "!": #go(error: .nestedComment, to: .commentEndBang)
            case "-": #go(error: .nestedComment, appendComment: "-")
            case "<": #go(error: .nestedComment, appendComment: "--<", to: .commentLessThanSign)
            case "\0": #go(error: .nestedComment, .unexpectedNull, appendComment: "--\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(error: .nestedComment, appendComment: "--\(c)", to: .comment)
            }
        } while true
        case .commentEndDash: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentEnd)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
        case .commentEnd: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitComment: .data)
            case "!": #go(to: .commentEndBang)
            case "-": #go(appendComment: "-")
            case "<": #go(appendComment: "--<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "--\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "--\(c)", to: .comment)
            }
        } while true
        case .commentEndBang: repeat {
            switch self.getChar(from: &input) {
            case "-": #go(appendComment: "--!", to: .commentEndDash)
            case ">": #go(error: .incorrectlyClosedComment, emitComment: .data)
            case "<": #go(appendComment: "--!<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "--!\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "--!\(c)", to: .comment)
            }
        } while true
        case .doctype: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeDOCTYPEName)
            case ">": #go(error: .missingDOCTYPEName, emitNewForceQuirksDOCTYPE: .data)
            case "\0": #go(error: .missingSpaceBeforeDOCTYPEName, .unexpectedNull, createDOCTYPE: "\u{FFFD}", to: .doctypeName)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitNewForceQuirksDOCTYPEAndEOF
            case let c?: #go(error: .missingSpaceBeforeDOCTYPEName, createDOCTYPE: lowerASCII(c), to: .doctypeName)
            }
        } while true
        case .beforeDOCTYPEName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\0": #go(error: .unexpectedNull, createDOCTYPE: "\u{FFFD}", to: .doctypeName)
            case ">": #go(error: .missingDOCTYPEName, emitNewForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitNewForceQuirksDOCTYPEAndEOF
            case let c?: #go(createDOCTYPE: lowerASCII(c), to: .doctypeName)
            }
        } while true
        case .doctypeName: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .afterDOCTYPEName)
            case ">": #go(emitDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendDOCTYPEName: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendDOCTYPEName: lowerASCII(c))
            }
        } while true
        case .afterDOCTYPEName: repeat {
            if self.starts(&input, with: "public") == true {
                #go(to: .afterDOCTYPEPublicKeyword)
            } else if self.starts(&input, with: "system") == true {
                #go(to: .afterDOCTYPESystemKeyword)
            } else {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case ">": #go(emitDOCTYPE: .data)
                case "\0": #go(error: .invalidCharSequence, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
                case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
                case _: #go(error: .invalidCharSequence, forceQuirks: .bogusDOCTYPE)
                }
            }
        } while true
        case .afterDOCTYPEPublicKeyword: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeDOCTYPEPublicID)
            case "\"": #go(error: .missingSpaceAfterDOCTYPEPublicKeyword, clearPublicID: .doctypePublicIDDoubleQuoted)
            case "'": #go(error: .missingSpaceAfterDOCTYPEPublicKeyword, clearPublicID: .doctypePublicIDSingleQuoted)
            case ">": #go(error: .missingDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPEPublicID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _: #go(error: .missingQuoteBeforeDOCTYPEPublicID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .beforeDOCTYPEPublicID: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\"": #go(clearPublicID: .doctypePublicIDDoubleQuoted)
            case "'": #go(clearPublicID: .doctypePublicIDSingleQuoted)
            case ">": #go(error: .missingDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPEPublicID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _: #go(error: .missingQuoteBeforeDOCTYPEPublicID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .doctypePublicIDDoubleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "\"": #go(to: .afterDOCTYPEPublicID)
            case ">": #go(error: .abruptDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendPublicID: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendPublicID: c)
            }
        } while true
        case .doctypePublicIDSingleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "'": #go(to: .afterDOCTYPEPublicID)
            case ">": #go(error: .abruptDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendPublicID: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendPublicID: c)
            }
        } while true
        case .afterDOCTYPEPublicID: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .betweenDOCTYPEPublicAndSystemIDs)
            case ">": #go(emitDOCTYPE: .data)
            case "\"": #go(error: .missingSpaceBetweenDOCTYPEIDs, clearSystemID: .doctypeSystemIDDoubleQuoted)
            case "'": #go(error: .missingSpaceBetweenDOCTYPEIDs, clearSystemID: .doctypeSystemIDSingleQuoted)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPESystemID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _?: #go(error: .missingQuoteBeforeDOCTYPESystemID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .betweenDOCTYPEPublicAndSystemIDs: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case ">": #go(emitDOCTYPE: .data)
            case "\"": #go(clearSystemID: .doctypeSystemIDDoubleQuoted)
            case "'": #go(clearSystemID: .doctypeSystemIDSingleQuoted)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPESystemID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _?: #go(error: .missingQuoteBeforeDOCTYPESystemID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .afterDOCTYPESystemKeyword: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeDOCTYPESystemID)
            case "\"": #go(error: .missingSpaceAfterDOCTYPESystemKeyword, clearSystemID: .doctypeSystemIDDoubleQuoted)
            case "'": #go(error: .missingSpaceAfterDOCTYPESystemKeyword, clearSystemID: .doctypeSystemIDSingleQuoted)
            case ">": #go(error: .missingDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPESystemID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _?: #go(error: .missingQuoteBeforeDOCTYPESystemID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .beforeDOCTYPESystemID: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\"": #go(clearSystemID: .doctypeSystemIDDoubleQuoted)
            case "'": #go(clearSystemID: .doctypeSystemIDSingleQuoted)
            case ">": #go(error: .missingDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .missingQuoteBeforeDOCTYPESystemID, .unexpectedNull, forceQuirks: .bogusDOCTYPE)
            case _?: #go(error: .missingQuoteBeforeDOCTYPESystemID, forceQuirks: .bogusDOCTYPE)
            }
        } while true
        case .doctypeSystemIDDoubleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "\"": #go(to: .afterDOCTYPESystemID)
            case "\0": #go(error: .unexpectedNull, appendSystemID: "\u{FFFD}")
            case ">": #go(error: .abruptDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendSystemID: c)
            }
        } while true
        case .doctypeSystemIDSingleQuoted: repeat {
            switch self.getChar(from: &input) {
            case "'": #go(to: .afterDOCTYPESystemID)
            case "\0": #go(error: .unexpectedNull, appendSystemID: "\u{FFFD}")
            case ">": #go(error: .abruptDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendSystemID: c)
            }
        } while true
        case .afterDOCTYPESystemID: repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case ">": #go(emitDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .unexpectedCharAfterDOCTYPE, .unexpectedNull, to: .bogusDOCTYPE)
            case _?: #go(error: .unexpectedCharAfterDOCTYPE, to: .bogusDOCTYPE)
            }
        } while true
        case .bogusDOCTYPE: repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitDOCTYPE: .data)
            case "\0": self.emitError(.unexpectedNull)
            case nil: #goEmitDOCTYPEAndEOF
            case _: break
            }
        } while true
        case .cdataSection: repeat {
            switch self.getChar(from: &input) {
            case "]": #go(to: .cdataSectionBracket)
            case nil: #go(error: .eofInCDATA, emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
        case .cdataSectionBracket: repeat {
            switch self.getChar(from: &input) {
            case "]": #go(to: .cdataSectionEnd)
            case nil: #go(error: .eofInCDATA, emit: "]", .eof)
            case let c?: #go(emit: "]", .char(c), to: .cdataSection)
            }
        } while true
        case .cdataSectionEnd: repeat {
            switch self.getChar(from: &input) {
            case "]": #go(emit: "]")
            case ">": #go(to: .data)
            case nil: #go(error: .eofInCDATA, emit: "]", .eof)
            case let c?: #go(emit: "]", .char(c), to: .cdataSection)
            }
        } while true
        }
    }

    @inline(__always)
    mutating func processCharRef(_ scalars: consuming [Unicode.Scalar]) {
        switch self.state {
        case .data, .rcdata: for scalar in scalars { #go(emit: Character(scalar)) }
        case .attributeValueDoubleQuoted, .attributeValueSingleQuoted, .attributeValueUnquoted:
            for scalar in scalars { #go(appendAttrValue: Character(scalar)) }
        case _: preconditionFailure("unreachable")
        }
    }

    @inline(__always)
    mutating func processCharRef(_ c: consuming Character) {
        switch self.state {
        case .data, .rcdata: #go(emit: c)
        case .attributeValueDoubleQuoted, .attributeValueSingleQuoted, .attributeValueUnquoted: #go(appendAttrValue: c)
        case _: preconditionFailure("unreachable")
        }
    }

    @inline(__always)
    private mutating func getChar(from input: inout Deque<Character>) -> Character? {
        guard let reconsumeChar else {
            guard let c = input.popFirst() else { return nil }
            guard c != "\r\n", c != "\r" else { return "\n" }
            switch c.firstScalar.value {
            // Swift's String cannot have surrogates
            // case 0xD800...0xDBFF, 0xDC00...0xDFFF:
            //     self.emitError(.surrogateInInput)
            case 0xFDD0...0xFDEF, 0xFFFE, 0xFFFF, 0x1FFFE, 0x1FFFF, 0x2FFFE, 0x2FFFF,
                0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE, 0x5FFFF, 0x6FFFE, 0x6FFFF,
                0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE, 0x9FFFF, 0xAFFFE, 0xAFFFF,
                0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF, 0xDFFFE, 0xDFFFF, 0xEFFFE, 0xEFFFF,
                0xFFFFE, 0xFFFFF, 0x10FFFE, 0x10FFFF:
                self.emitError(.noncharacterInInput)
            case 0x01...0x08, 0x0B, 0x0E...0x1F, 0x7F...0x9F:
                self.emitError(.controlCharInInput)
            case _: break
            }
            return c
        }
        self.reconsumeChar = nil
        return reconsumeChar
    }

    @inline(__always)
    func peek(_ input: borrowing Deque<Character>) -> Character? {
        self.reconsumeChar ?? input.first
    }

    @inline(__always)
    mutating func discardChar(_ input: inout Deque<Character>) {
        switch self.reconsumeChar {
        case .some: self.reconsumeChar = nil
        case .none: input.removeFirst()
        }
    }

    @inline(__always)
    private mutating func startsExact(
        _ input: inout Deque<Character>,
        with pattern: consuming some StringProtocol
    ) -> Bool? {
        var iter = input.makeIterator()
        let count = pattern.count
        for pc in pattern {
            guard let c = iter.next() else { return nil }
            guard consume c == consume pc else { return false }
        }
        input.removeFirst(count)
        return true
    }

    @inline(__always)
    private mutating func starts(
        _ input: inout Deque<Character>,
        with pattern: consuming some StringProtocol
    ) -> Bool? {
        var iter = input.makeIterator()
        let count = pattern.count
        for pc in pattern {
            guard let c = iter.next() else { return nil }
            guard c.lowercased() == pc.lowercased() else { return false }
        }
        input.removeFirst(count)
        return true
    }

    @inline(__always)
    private mutating func go(to state: consuming State) {
        self.state = state
    }

    @inline(__always)
    private mutating func go(reconsume c: consuming Character, in state: consuming State) {
        self.reconsumeChar = c
        self.state = state
    }

    @inline(__always)
    private mutating func emit(_ c: consuming Character) {
        self.sink.process(.char(c))
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func emit(_ token: consuming Token) {
        self.sink.process(token)
    }

    @inline(__always)
    private mutating func emitEOF() {
        self.sink.process(.eof)
    }

    @inline(__always)
    mutating func emitError(_ error: consuming ParseError) {
        self.sink.process(.error(error))
    }

    @inline(__always)
    private mutating func createTempBuffer(with c: consuming Character) {
        self.tempBuffer = String(c)
    }

    @inline(__always)
    private mutating func emitTempBuffer() {
        for c in self.tempBuffer {
            self.sink.process(.char(c))
        }
        self.tempBuffer.removeAll()
    }

    @inline(__always)
    private mutating func createComment(with c: consuming Character) {
        self.currentComment = String(c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createComment(with s: consuming String) {
        self.currentComment = s
    }

    @inline(__always)
    private mutating func appendComment(_ c: consuming Character) {
        self.currentComment.append(c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendComment(_ s: consuming String) {
        self.currentComment += s
    }

    @inline(__always)
    private mutating func emitComment() {
        self.sink.process(.comment(self.currentComment))
    }

    @inline(__always)
    private mutating func createStartTag(with c: consuming Character) {
        self.currentTagName = String(c)
        self.currentTagKind = .start
        self.currentAttrs.removeAll()
    }

    @inline(__always)
    private mutating func createEndTag(with c: consuming Character) {
        self.currentTagName = String(c)
        self.currentTagKind = .end
        self.currentAttrs.removeAll()
    }

    @inline(__always)
    private mutating func createAttr(with c: consuming Character) {
        self.pushAttr()
        self.currentAttrName = String(c)
    }

    @inline(__always)
    private mutating func pushAttr() {
        guard !self.currentAttrName.isEmpty else { return }
        if self.currentAttrs.keys.contains(self.currentAttrName) {
            self.emitError(.duplicateAttr)
        } else {
            self.currentAttrs[self.currentAttrName] = self.currentAttrValue
        }
        self.currentAttrName.removeAll()
        self.currentAttrValue.removeAll()
    }

    @inline(__always)
    private mutating func emitTag(selfClosing: Bool = false) {
        self.pushAttr()

        let name = self.currentTagName
        let attrs = self.currentAttrs

        switch self.currentTagKind {
        case .start:
            self.lastStartTagName = name
            self.sink.process(.tag(Tag(name: name, kind: .start, attrs: attrs, selfClosing: selfClosing)))
        case .end:
            if !attrs.isEmpty { self.emitError(.endTagWithAttrs) }
            if selfClosing { self.emitError(.endTagWithTrailingSolidus) }
            self.sink.process(.tag(Tag(name: name, kind: .end, attrs: [:], selfClosing: false)))
        }
    }

    @inline(__always)
    private mutating func createDOCTYPE() {
        self.currentDOCTYPE = .init()
    }

    @inline(__always)
    private mutating func createDOCTYPE(with c: consuming Character) {
        self.currentDOCTYPE = .init(name: String(c))
    }

    @inline(__always)
    private mutating func appendDOCTYPEName(_ c: consuming Character) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(c)
        case .none: self.currentDOCTYPE.name = String(c)
        }
    }

    @inline(__always)
    private mutating func appendPublicID(_ c: consuming Character) {
        switch self.currentDOCTYPE.publicID {
        case .some: self.currentDOCTYPE.publicID?.append(c)
        case .none: self.currentDOCTYPE.publicID = String(c)
        }
    }

    @inline(__always)
    private mutating func clearPublicID() {
        self.currentDOCTYPE.publicID = ""
    }

    @inline(__always)
    private mutating func appendSystemID(_ c: consuming Character) {
        switch self.currentDOCTYPE.systemID {
        case .some: self.currentDOCTYPE.systemID?.append(c)
        case .none: self.currentDOCTYPE.systemID = String(c)
        }
    }

    @inline(__always)
    private mutating func clearSystemID() {
        self.currentDOCTYPE.systemID = ""
    }

    @inline(__always)
    private mutating func forceQuirks() {
        self.currentDOCTYPE.forceQuirks = true
    }

    @inline(__always)
    private mutating func emitDOCTYPE() {
        self.sink.process(.doctype(self.currentDOCTYPE))
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenizer = .init()
    }
}

extension Tokenizer: Sendable where Sink: Sendable {}
