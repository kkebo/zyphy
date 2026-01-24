private import DequeModule
private import Str

public struct Tokenizer<Sink: ~Copyable & TokenSink>: ~Copyable {
    public var sink: Sink
    public var emitsAllErrors: Bool
    package var state: State
    private var reconsumeChar: Optional<Char>
    private var tempBuffer: Str
    private var currentComment: Str
    private var currentTagName: Str
    private var currentTagKind: TagKind
    private var currentAttrName: Str
    private var currentAttrValue: Str
    private var currentAttrs: [Str: Str]
    private var lastStartTagName: Optional<Str>
    private var currentDOCTYPE: DOCTYPE

    public init(sink: consuming Sink, emitsAllErrors: Bool = false) {
        self.sink = sink
        self.emitsAllErrors = emitsAllErrors
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
    }

    public mutating func tokenize(_ input: inout BufferQueue) {
        repeat {
            switch self.step(&input) {
            case .continue: break
            case .suspend: return
            }
        } while true
    }

    @_transparent
    private mutating func step(_ input: inout BufferQueue) -> ProcessResult {
        switch self.state {
        case .data: self.data(&input)
        case .rcdata: self.rcdata(&input)
        case .rawtext: self.rawtext(&input)
        case .scriptData: self.scriptData(&input)
        case .plaintext: self.plaintext(&input)
        case .tagOpen: self.tagOpen(&input)
        case .endTagOpen: self.endTagOpen(&input)
        case .tagName: self.tagName(&input)
        case .rcdataLessThanSign: self.rcdataLessThanSign(&input)
        case .rcdataEndTagOpen: self.rcdataEndTagOpen(&input)
        case .rcdataEndTagName: self.rcdataEndTagName(&input)
        case .rawtextLessThanSign: self.rawtextLessThanSign(&input)
        case .rawtextEndTagOpen: self.rawtextEndTagOpen(&input)
        case .rawtextEndTagName: self.rawtextEndTagName(&input)
        case .scriptDataLessThanSign: self.scriptDataLessThanSign(&input)
        case .scriptDataEndTagOpen: self.scriptDataEndTagOpen(&input)
        case .scriptDataEndTagName: self.scriptDataEndTagName(&input)
        case .scriptDataEscapeStart: self.scriptDataEscapeStart(&input)
        case .scriptDataEscapeStartDash: self.scriptDataEscapeStartDash(&input)
        case .scriptDataEscaped: self.scriptDataEscaped(&input)
        case .scriptDataEscapedDash: self.scriptDataEscapedDash(&input)
        case .scriptDataEscapedDashDash: self.scriptDataEscapedDashDash(&input)
        case .scriptDataEscapedLessThanSign: self.scriptDataEscapedLessThanSign(&input)
        case .scriptDataEscapedEndTagOpen: self.scriptDataEscapedEndTagOpen(&input)
        case .scriptDataEscapedEndTagName: self.scriptDataEscapedEndTagName(&input)
        case .scriptDataDoubleEscapeStart: self.scriptDataDoubleEscapeStart(&input)
        case .scriptDataDoubleEscaped: self.scriptDataDoubleEscaped(&input)
        case .scriptDataDoubleEscapedDash: self.scriptDataDoubleEscapedDash(&input)
        case .scriptDataDoubleEscapedDashDash: self.scriptDataDoubleEscapedDashDash(&input)
        case .scriptDataDoubleEscapedLessThanSign: self.scriptDataDoubleEscapedLessThanSign(&input)
        case .scriptDataDoubleEscapeEnd: self.scriptDataDoubleEscapeEnd(&input)
        case .beforeAttributeName: self.beforeAttributeName(&input)
        case .attributeName: self.attributeName(&input)
        case .afterAttributeName: self.afterAttributeName(&input)
        case .beforeAttributeValue: self.beforeAttributeValue(&input)
        case .attributeValueDoubleQuoted: self.attributeValueDoubleQuoted(&input)
        case .attributeValueSingleQuoted: self.attributeValueSingleQuoted(&input)
        case .attributeValueUnquoted: self.attributeValueUnquoted(&input)
        case .afterAttributeValueQuoted: self.afterAttributeValueQuoted(&input)
        case .selfClosingStartTag: self.selfClosingStartTag(&input)
        case .bogusComment: self.bogusComment(&input)
        case .markupDeclarationOpen: self.markupDeclarationOpen(&input)
        case .commentStart: self.commentStart(&input)
        case .commentStartDash: self.commentStartDash(&input)
        case .comment: self.comment(&input)
        case .commentLessThanSign: self.commentLessThanSign(&input)
        case .commentLessThanSignBang: self.commentLessThanSignBang(&input)
        case .commentLessThanSignBangDash: self.commentLessThanSignBangDash(&input)
        case .commentLessThanSignBangDashDash: self.commentLessThanSignBangDashDash(&input)
        case .commentEndDash: self.commentEndDash(&input)
        case .commentEnd: self.commentEnd(&input)
        case .commentEndBang: self.commentEndBang(&input)
        case .doctype: self.doctype(&input)
        case .beforeDOCTYPEName: self.beforeDOCTYPEName(&input)
        case .doctypeName: self.doctypeName(&input)
        case .afterDOCTYPEName: self.afterDOCTYPEName(&input)
        case .afterDOCTYPEPublicKeyword: self.afterDOCTYPEPublicKeyword(&input)
        case .beforeDOCTYPEPublicID: self.beforeDOCTYPEPublicID(&input)
        case .doctypePublicIDDoubleQuoted: self.doctypePublicIDDoubleQuoted(&input)
        case .doctypePublicIDSingleQuoted: self.doctypePublicIDSingleQuoted(&input)
        case .afterDOCTYPEPublicID: self.afterDOCTYPEPublicID(&input)
        case .betweenDOCTYPEPublicAndSystemIDs: self.betweenDOCTYPEPublicAndSystemIDs(&input)
        case .afterDOCTYPESystemKeyword: self.afterDOCTYPESystemKeyword(&input)
        case .beforeDOCTYPESystemID: self.beforeDOCTYPESystemID(&input)
        case .doctypeSystemIDDoubleQuoted: self.doctypeSystemIDDoubleQuoted(&input)
        case .doctypeSystemIDSingleQuoted: self.doctypeSystemIDSingleQuoted(&input)
        case .afterDOCTYPESystemID: self.afterDOCTYPESystemID(&input)
        case .bogusDOCTYPE: self.bogusDOCTYPE(&input)
        case .cdataSection: self.cdataSection(&input)
        case .cdataSectionBracket: self.cdataSectionBracket(&input)
        case .cdataSectionEnd: self.cdataSectionEnd(&input)
        }
    }

    private mutating func data(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "&", "<", "\0"]) {
            case .known("&"): self.consumeCharRef(inAttr: false, input: &input)
            case .known("<"): #go(to: .tagOpen)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\0")
            case nil: #go(emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func rcdata(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "&", "<", "\0"]) {
            case .known("&"): self.consumeCharRef(inAttr: false, input: &input)
            case .known("<"): #go(to: .rcdataLessThanSign)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func rawtext(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "<", "\0"]) {
            case .known("<"): #go(to: .rawtextLessThanSign)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func scriptData(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "<", "\0"]) {
            case .known("<"): #go(to: .scriptDataLessThanSign)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func plaintext(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "\0"]) {
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func tagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func endTagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func tagName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "\0": #go(error: .unexpectedNull, appendTagName: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(appendTagName: lowerASCII(c))
            }
        } while true
    }

    private mutating func rcdataLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .rcdataEndTagOpen)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", reconsume: c, in: .rcdata)
            }
        } while true
    }

    private mutating func rcdataEndTagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .rcdataEndTagName)
                case nil: #go(emit: "<", "/", reconsume: c, in: .rcdata)
                }
            case nil: #go(emit: "<", "/", .eof)
            }
        } while true
    }

    private mutating func rcdataEndTagName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            let c = self.getChar(from: &input)
            if case .end = self.currentTagKind, self.currentTagName == self.lastStartTagName {
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
    }

    private mutating func rawtextLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .rawtextEndTagOpen)
            case "<": #go(emit: "<", to: .rawtextLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .rawtext)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", c, to: .rawtext)
            }
        } while true
    }

    private mutating func rawtextEndTagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "<": #go(emit: "<", "/", to: .rawtextLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "/", "\u{FFFD}", to: .rawtext)
            case nil: #go(emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .rawtextEndTagName)
                case nil: #go(emit: "<", "/", c, to: .rawtext)
                }
            }
        } while true
    }

    private mutating func rawtextEndTagName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            let c = self.getChar(from: &input)
            if case .end = self.currentTagKind, self.currentTagName == self.lastStartTagName {
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
    }

    private mutating func scriptDataLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .scriptDataEndTagOpen)
            case "!": #go(emit: "<", "!", to: .scriptDataEscapeStart)
            case "<": #go(emit: "<", to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .scriptData)
            case nil: #go(emit: "<", .eof)
            case let c?: #go(emit: "<", c, to: .scriptData)
            }
        } while true
    }

    private mutating func scriptDataEndTagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "<": #go(emit: "<", "/", to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", ",", "\u{FFFD}", to: .scriptData)
            case nil: #go(emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .scriptDataEndTagName)
                case nil: #go(emit: "<", "/", c, to: .scriptData)
                }
            }
        } while true
    }

    private mutating func scriptDataEndTagName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            let c = self.getChar(from: &input)
            if case .end = self.currentTagKind, self.currentTagName == self.lastStartTagName {
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
    }

    private mutating func scriptDataEscapeStart(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapeStartDash)
            case "<": #go(to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
    }

    private mutating func scriptDataEscapeStartDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapedDashDash)
            case "<": #go(to: .scriptDataLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
    }

    private mutating func scriptDataEscaped(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "-", "<", "\0"]) {
            case .known("-"): #go(emit: "-", to: .scriptDataEscapedDash)
            case .known("<"): #go(to: .scriptDataEscapedLessThanSign)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func scriptDataEscapedDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataEscapedDashDash)
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c, to: .scriptDataEscaped)
            }
        } while true
    }

    private mutating func scriptDataEscapedDashDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-")
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case ">": #go(emit: ">", to: .scriptData)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c, to: .scriptDataEscaped)
            }
        } while true
    }

    private mutating func scriptDataEscapedLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "/": #go(clearTemp: .scriptDataEscapedEndTagOpen)
            case "-": #go(emit: "<", "-", to: .scriptDataEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: "<", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createTemp: cl, emit: "<", c, to: .scriptDataDoubleEscapeStart)
                case nil: #go(emit: "<", c, to: .scriptDataEscaped)
                }
            }
        } while true
    }

    private mutating func scriptDataEscapedEndTagOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "<", "/", "-", to: .scriptDataEscapedDash)
            case "<": #go(emit: "<", "/", to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "<", "/", "\u{FFFD}", to: .scriptDataEscaped)
            case nil: #go(error: .eofInScriptComment, emit: "<", "/", .eof)
            case let c?:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(createEndTag: cl, appendTemp: c, to: .scriptDataEscapedEndTagName)
                case nil: #go(emit: "<", "/", c, to: .scriptDataEscaped)
                }
            }
        } while true
    }

    private mutating func scriptDataEscapedEndTagName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            let c = self.getChar(from: &input)
            if case .end = self.currentTagKind, self.currentTagName == self.lastStartTagName {
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
    }

    private mutating func scriptDataDoubleEscapeStart(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            guard let c = self.getChar(from: &input) else { #go(error: .eofInScriptComment, emit: .eof) }
            switch c {
            case "\t", "\n", "\u{0C}", " ", "/", ">":
                if self.tempBuffer == "script" {
                    #go(emit: c, to: .scriptDataDoubleEscaped)
                } else {
                    #go(emit: c, to: .scriptDataEscaped)
                }
            case "-": #go(emit: "-", to: .scriptDataEscapedDash)
            case "<": #go(to: .scriptDataEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataEscaped)
            case let c:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTemp: cl, emit: c)
                case nil: #go(emit: c, to: .scriptDataEscaped)
                }
            }
        } while true
    }

    private mutating func scriptDataDoubleEscaped(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "-", "<", "\0"]) {
            case .known("-"): #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case .known("<"): #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case .known("\0"): #go(error: .unexpectedNull, emit: "\u{FFFD}")
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case .known(let c): #go(emit: c)
            case .others(let s): #go(emit: s)
            }
        } while true
    }

    private mutating func scriptDataDoubleEscapedDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDashDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c, to: .scriptDataDoubleEscaped)
            }
        } while true
    }

    private mutating func scriptDataDoubleEscapedDashDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(emit: "-")
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case ">": #go(emit: ">", to: .scriptData)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c, to: .scriptDataDoubleEscaped)
            }
        } while true
    }

    private mutating func scriptDataDoubleEscapedLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "/": #go(emit: "/", clearTemp: .scriptDataDoubleEscapeEnd)
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case nil: #go(error: .eofInScriptComment, emit: .eof)
            case let c?: #go(emit: c, to: .scriptDataDoubleEscaped)
            }
        } while true
    }

    private mutating func scriptDataDoubleEscapeEnd(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            guard let c = self.getChar(from: &input) else { #go(error: .eofInScriptComment, emit: .eof) }
            switch c {
            case "\t", "\n", "\u{0C}", " ", "/", ">":
                if self.tempBuffer == "script" {
                    #go(emit: c, to: .scriptDataEscaped)
                } else {
                    #go(emit: c, to: .scriptDataDoubleEscaped)
                }
            case "-": #go(emit: "-", to: .scriptDataDoubleEscapedDash)
            case "<": #go(emit: "<", to: .scriptDataDoubleEscapedLessThanSign)
            case "\0": #go(error: .unexpectedNull, emit: "\u{FFFD}", to: .scriptDataDoubleEscaped)
            case let c:
                switch lowerASCIIOrNil(c) {
                case let cl?: #go(appendTemp: cl, emit: c)
                case nil: #go(emit: c, to: .scriptDataDoubleEscaped)
                }
            }
        } while true
    }

    private mutating func beforeAttributeName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func attributeName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func afterAttributeName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func beforeAttributeValue(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\"": #go(to: .attributeValueDoubleQuoted)
            case "'": #go(to: .attributeValueSingleQuoted)
            case ">": #go(error: .missingAttrValue, emitTag: .data)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(reconsume: c, in: .attributeValueUnquoted)
            }
        } while true
    }

    private mutating func attributeValueDoubleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "\"", "&", "\0"]) {
            case .known("\""): #go(to: .afterAttributeValueQuoted)
            case .known("&"): self.consumeCharRef(inAttr: true, input: &input)
            case .known("\0"): #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case .known(let c): #go(appendAttrValue: c)
            case .others(let s): #go(appendAttrValue: s)
            }
        } while true
    }

    private mutating func attributeValueSingleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(from: &input, except: ["\r", "\n", "'", "&", "\0"]) {
            case .known("'"): #go(to: .afterAttributeValueQuoted)
            case .known("&"): self.consumeCharRef(inAttr: true, input: &input)
            case .known("\0"): #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case .known(let c): #go(appendAttrValue: c)
            case .others(let s): #go(appendAttrValue: s)
            }
        } while true
    }

    private mutating func attributeValueUnquoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.pop(
                from: &input,
                except: ["\r", "\n", "\t", "\u{0C}", " ", "&", ">", "\0", "\"", "'", "<", "=", "`"],
            ) {
            case .known("\t"): #go(to: .beforeAttributeName)
            case .known("\n"): #go(to: .beforeAttributeName)
            case .known("\u{0C}"): #go(to: .beforeAttributeName)
            case .known(" "): #go(to: .beforeAttributeName)
            case .known("&"): self.consumeCharRef(inAttr: true, input: &input)
            case .known(">"): #go(emitTag: .data)
            case .known("\0"): #go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
            case nil: #go(error: .eofInTag, emit: .eof)
            case .known("\""): #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
            case .known("'"): #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "'")
            case .known("<"): #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "<")
            case .known("="): #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "=")
            case .known("`"): #go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "`")
            case .known(let c): #go(appendAttrValue: c)
            case .others(let s): #go(appendAttrValue: s)
            }
        } while true
    }

    private mutating func afterAttributeValueQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeAttributeName)
            case "/": #go(to: .selfClosingStartTag)
            case ">": #go(emitTag: .data)
            case "=": #go(error: .missingSpaceBetweenAttrs, .unexpectedEqualsSign, createAttr: "=", to: .attributeName)
            case "\0":
                #go(error: .missingSpaceBetweenAttrs, .unexpectedNull, createAttr: "\u{FFFD}", to: .attributeName)
            case "\"":
                #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "\"", to: .attributeName)
            case "'":
                #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "'", to: .attributeName)
            case "<":
                #go(error: .missingSpaceBetweenAttrs, .unexpectedCharInAttrName, createAttr: "<", to: .attributeName)
            case nil: #go(error: .eofInTag, emit: .eof)
            case let c?: #go(error: .missingSpaceBetweenAttrs, createAttr: lowerASCII(c), to: .attributeName)
            }
        } while true
    }

    private mutating func selfClosingStartTag(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func bogusComment(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitComment: .data)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}")
            case nil: #goEmitCommentAndEOF
            case let c?: #go(appendComment: c)
            }
        } while true
    }

    private mutating func markupDeclarationOpen(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func commentStart(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentStartDash)
            case ">": #go(error: .abruptClosingComment, emitComment: .data)
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
    }

    private mutating func commentStartDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentEnd)
            case ">": #go(error: .abruptClosingComment, emitComment: .data)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
    }

    private mutating func comment(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "-": #go(to: .commentEndDash)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}")
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c)
            }
        } while true
    }

    private mutating func commentLessThanSign(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "!": #go(appendComment: "!", to: .commentLessThanSignBang)
            case "<": #go(appendComment: "<")
            case "-": #go(to: .commentEndDash)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
    }

    private mutating func commentLessThanSignBang(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentLessThanSignBangDash)
            case "<": #go(appendComment: "<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: c, to: .comment)
            }
        } while true
    }

    private mutating func commentLessThanSignBangDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentLessThanSignBangDashDash)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
    }

    private mutating func commentLessThanSignBangDashDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func commentEndDash(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(to: .commentEnd)
            case "<": #go(appendComment: "-<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "-\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "-\(c)", to: .comment)
            }
        } while true
    }

    private mutating func commentEnd(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func commentEndBang(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "-": #go(appendComment: "--!", to: .commentEndDash)
            case ">": #go(error: .incorrectlyClosedComment, emitComment: .data)
            case "<": #go(appendComment: "--!<", to: .commentLessThanSign)
            case "\0": #go(error: .unexpectedNull, appendComment: "--!\u{FFFD}", to: .comment)
            case nil: self.emitError(.eofInComment); #goEmitCommentAndEOF
            case let c?: #go(appendComment: "--!\(c)", to: .comment)
            }
        } while true
    }

    private mutating func doctype(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .beforeDOCTYPEName)
            case ">": #go(error: .missingDOCTYPEName, emitNewForceQuirksDOCTYPE: .data)
            case "\0":
                #go(error: .missingSpaceBeforeDOCTYPEName, .unexpectedNull, createDOCTYPE: "\u{FFFD}", to: .doctypeName)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitNewForceQuirksDOCTYPEAndEOF
            case let c?: #go(error: .missingSpaceBeforeDOCTYPEName, createDOCTYPE: lowerASCII(c), to: .doctypeName)
            }
        } while true
    }

    private mutating func beforeDOCTYPEName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case "\0": #go(error: .unexpectedNull, createDOCTYPE: "\u{FFFD}", to: .doctypeName)
            case ">": #go(error: .missingDOCTYPEName, emitNewForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitNewForceQuirksDOCTYPEAndEOF
            case let c?: #go(createDOCTYPE: lowerASCII(c), to: .doctypeName)
            }
        } while true
    }

    private mutating func doctypeName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": #go(to: .afterDOCTYPEName)
            case ">": #go(emitDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendDOCTYPEName: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendDOCTYPEName: lowerASCII(c))
            }
        } while true
    }

    private mutating func afterDOCTYPEName(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func afterDOCTYPEPublicKeyword(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func beforeDOCTYPEPublicID(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func doctypePublicIDDoubleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\"": #go(to: .afterDOCTYPEPublicID)
            case ">": #go(error: .abruptDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendPublicID: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendPublicID: c)
            }
        } while true
    }

    private mutating func doctypePublicIDSingleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "'": #go(to: .afterDOCTYPEPublicID)
            case ">": #go(error: .abruptDOCTYPEPublicID, emitForceQuirksDOCTYPE: .data)
            case "\0": #go(error: .unexpectedNull, appendPublicID: "\u{FFFD}")
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendPublicID: c)
            }
        } while true
    }

    private mutating func afterDOCTYPEPublicID(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func betweenDOCTYPEPublicAndSystemIDs(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func afterDOCTYPESystemKeyword(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func beforeDOCTYPESystemID(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
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
    }

    private mutating func doctypeSystemIDDoubleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\"": #go(to: .afterDOCTYPESystemID)
            case "\0": #go(error: .unexpectedNull, appendSystemID: "\u{FFFD}")
            case ">": #go(error: .abruptDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendSystemID: c)
            }
        } while true
    }

    private mutating func doctypeSystemIDSingleQuoted(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "'": #go(to: .afterDOCTYPESystemID)
            case "\0": #go(error: .unexpectedNull, appendSystemID: "\u{FFFD}")
            case ">": #go(error: .abruptDOCTYPESystemID, emitForceQuirksDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case let c?: #go(appendSystemID: c)
            }
        } while true
    }

    private mutating func afterDOCTYPESystemID(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "\t", "\n", "\u{0C}", " ": break
            case ">": #go(emitDOCTYPE: .data)
            case nil: self.emitError(.eofInDOCTYPE); #goEmitForceQuirksDOCTYPEAndEOF
            case "\0": #go(error: .unexpectedCharAfterDOCTYPE, .unexpectedNull, to: .bogusDOCTYPE)
            case _?: #go(error: .unexpectedCharAfterDOCTYPE, to: .bogusDOCTYPE)
            }
        } while true
    }

    private mutating func bogusDOCTYPE(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case ">": #go(emitDOCTYPE: .data)
            case "\0": self.emitError(.unexpectedNull)
            case nil: #goEmitDOCTYPEAndEOF
            case _: break
            }
        } while true
    }

    private mutating func cdataSection(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "]": #go(to: .cdataSectionBracket)
            case nil: #go(error: .eofInCDATA, emit: .eof)
            case let c?: #go(emit: c)
            }
        } while true
    }

    private mutating func cdataSectionBracket(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "]": #go(to: .cdataSectionEnd)
            case nil: #go(error: .eofInCDATA, emit: "]", .eof)
            case let c?: #go(emit: "]", c, to: .cdataSection)
            }
        } while true
    }

    private mutating func cdataSectionEnd(_ input: inout BufferQueue) -> ProcessResult {
        repeat {
            switch self.getChar(from: &input) {
            case "]": #go(emit: "]")
            case ">": #go(to: .data)
            case nil: #go(error: .eofInCDATA, emit: "]", .eof)
            case let c?: #go(emit: "]", c, to: .cdataSection)
            }
        } while true
    }

    @_transparent
    private mutating func processCharRef(_ c1: consuming Char, _ c2: consuming Char) {
        switch self.state {
        case .data, .rcdata: #go(emit: c1, c2)
        case .attributeValueDoubleQuoted, .attributeValueSingleQuoted, .attributeValueUnquoted:
            #go(appendAttrValue: c1, c2)
        case _: preconditionFailure("unreachable")
        }
    }

    @_transparent
    private mutating func processCharRef(_ c: consuming Char) {
        switch self.state {
        case .data, .rcdata: #go(emit: c)
        case .attributeValueDoubleQuoted, .attributeValueSingleQuoted, .attributeValueUnquoted: #go(appendAttrValue: c)
        case _: preconditionFailure("unreachable")
        }
    }

    private mutating func pop(from input: inout BufferQueue, except s: consuming SmallCharSet) -> PopResult? {
        guard !self.emitsAllErrors, self.reconsumeChar == nil else {
            return self.getChar(from: &input).map(PopResult.known)
        }
        return switch input.pop(except: s) {
        case .known(let c): .known(self.preprocess(c, input: &input))
        case let other: other
        }
    }

    private mutating func preprocess(_ c: consuming Char, input: inout BufferQueue) -> Char {
        guard c != "\r" else {
            if input.peek() == "\n" { input.removeFirst() }
            return "\n"
        }
        if self.emitsAllErrors {
            switch c.value {
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
        }
        return c
    }

    private mutating func getChar(from input: inout BufferQueue) -> Char? {
        guard let reconsumeChar else {
            return input.popFirst().map { self.preprocess($0, input: &input) }
        }
        self.reconsumeChar = nil
        return reconsumeChar
    }

    private mutating func startsExact(_ input: inout BufferQueue, with pattern: consuming Str) -> Bool? {
        guard !input.buffers.isEmpty else { return nil }
        var bufIndex = 0
        var i = 0
        for pc in pattern {
            guard bufIndex < input.buffers.count else { return nil }
            let buf = input.buffers[bufIndex]
            let c = buf[buf.startIndex + i]
            guard c == pc else { return false }
            i += 1
            if buf.startIndex + i >= buf.endIndex {
                bufIndex += 1
                i = 0
            }
        }
        input.buffers.removeFirst(bufIndex)
        if !input.buffers.isEmpty {
            input.buffers[0].removeFirst(i)
        }
        return true
    }

    private mutating func starts(_ input: inout BufferQueue, with pattern: consuming Str) -> Bool? {
        guard !input.buffers.isEmpty else { return nil }
        var bufIndex = 0
        var i = 0
        for pc in pattern {
            guard bufIndex < input.buffers.count else { return nil }
            let buf = input.buffers[bufIndex]
            let c = buf[buf.startIndex + i]
            guard lowerASCII(c) == lowerASCII(pc) else { return false }
            i += 1
            if buf.startIndex + i >= buf.endIndex {
                bufIndex += 1
                i = 0
            }
        }
        input.buffers.removeFirst(bufIndex)
        if !input.buffers.isEmpty {
            input.buffers[0].removeFirst(i)
        }
        return true
    }

    @_transparent
    private mutating func go(to state: consuming State) {
        self.state = state
    }

    @_transparent
    private mutating func go(reconsume c: consuming Char, in state: consuming State) {
        self.reconsumeChar = c
        self.state = state
    }

    @_transparent
    private mutating func emit(_ c: consuming Char) {
        self.sink.process(.char(c))
    }

    @_disfavoredOverload
    @_transparent
    private mutating func emit(_ s: consuming StrSlice) {
        self.sink.process(.chars(s))
    }

    @_transparent
    private mutating func emit(_ token: consuming Token) {
        self.sink.process(token)
    }

    @_transparent
    private mutating func emitEOF() {
        self.sink.process(.eof)
    }

    @_transparent
    mutating func emitError(_ error: consuming ParseError) {
        self.sink.process(.error(error))
    }

    @_transparent
    private mutating func createTempBuffer(with c: consuming Char) {
        self.tempBuffer.removeAll(keepingCapacity: true)
        self.tempBuffer.append(c)
    }

    @_transparent
    private mutating func appendTempBuffer(_ c: consuming Char) {
        self.tempBuffer.append(c)
    }

    @_transparent
    private mutating func clearTempBuffer() {
        self.tempBuffer.removeAll(keepingCapacity: true)
    }

    @_transparent
    private mutating func emitTempBuffer() {
        self.emit(ArraySlice(self.tempBuffer))
        self.tempBuffer.removeAll(keepingCapacity: true)
    }

    @_transparent
    private mutating func createComment(with c: consuming Char) {
        self.currentComment.removeAll(keepingCapacity: true)
        self.currentComment.append(c)
    }

    @_disfavoredOverload
    @_transparent
    private mutating func createComment(with s: consuming Str) {
        self.currentComment = s
    }

    @_transparent
    private mutating func appendComment(_ c: consuming Char) {
        self.currentComment.append(c)
    }

    @_disfavoredOverload
    @_transparent
    private mutating func appendComment(_ s: consuming Str) {
        self.currentComment += s
    }

    @_transparent
    private mutating func clearComment() {
        self.currentComment.removeAll(keepingCapacity: true)
    }

    @_transparent
    private mutating func emitComment() {
        self.sink.process(.comment(self.currentComment))
    }

    @_transparent
    private mutating func createStartTag(with c: consuming Char) {
        self.currentTagName.removeAll(keepingCapacity: true)
        self.currentTagName.append(c)
        self.currentTagKind = .start
        self.currentAttrs.removeAll(keepingCapacity: true)
    }

    @_transparent
    private mutating func createEndTag(with c: consuming Char) {
        self.currentTagName.removeAll(keepingCapacity: true)
        self.currentTagName.append(c)
        self.currentTagKind = .end
        self.currentAttrs.removeAll(keepingCapacity: true)
    }

    @_transparent
    private mutating func appendTagName(_ c: consuming Char) {
        self.currentTagName.append(c)
    }

    @_transparent
    private mutating func createAttr(with c: consuming Char) {
        self.pushAttr()
        self.currentAttrName.append(c)
    }

    @_transparent
    private mutating func appendAttrName(_ c: consuming Char) {
        self.currentAttrName.append(c)
    }

    @_transparent
    private mutating func appendAttrValue(_ c: consuming Char) {
        self.currentAttrValue.append(c)
    }

    @_disfavoredOverload
    @_transparent
    private mutating func appendAttrValue(_ s: consuming StrSlice) {
        self.currentAttrValue += s
    }

    @_transparent
    private mutating func pushAttr() {
        guard !self.currentAttrName.isEmpty else { return }
        if self.currentAttrs.keys.contains(self.currentAttrName) {
            self.emitError(.duplicateAttr)
        } else {
            self.currentAttrs[self.currentAttrName] = self.currentAttrValue
        }
        self.currentAttrName.removeAll(keepingCapacity: true)
        self.currentAttrValue.removeAll(keepingCapacity: true)
    }

    @_transparent
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

    @_transparent
    private mutating func createDOCTYPE() {
        self.currentDOCTYPE = .init()
    }

    @_transparent
    private mutating func createDOCTYPE(with c: consuming Char) {
        self.currentDOCTYPE = .init(name: .init(c))
    }

    @_transparent
    private mutating func appendDOCTYPEName(_ c: consuming Char) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(c)
        case .none: self.currentDOCTYPE.name = .init(c)
        }
    }

    @_transparent
    private mutating func appendPublicID(_ c: consuming Char) {
        switch self.currentDOCTYPE.publicID {
        case .some: self.currentDOCTYPE.publicID?.append(c)
        case .none: self.currentDOCTYPE.publicID = .init(c)
        }
    }

    @_transparent
    private mutating func clearPublicID() {
        switch self.currentDOCTYPE.publicID {
        case .some: self.currentDOCTYPE.publicID?.removeAll(keepingCapacity: true)
        case .none: self.currentDOCTYPE.publicID = ""
        }
    }

    @_transparent
    private mutating func appendSystemID(_ c: consuming Char) {
        switch self.currentDOCTYPE.systemID {
        case .some: self.currentDOCTYPE.systemID?.append(c)
        case .none: self.currentDOCTYPE.systemID = .init(c)
        }
    }

    @_transparent
    private mutating func clearSystemID() {
        switch self.currentDOCTYPE.systemID {
        case .some: self.currentDOCTYPE.systemID?.removeAll(keepingCapacity: true)
        case .none: self.currentDOCTYPE.systemID = ""
        }
    }

    @_transparent
    private mutating func forceQuirks() {
        self.currentDOCTYPE.forceQuirks = true
    }

    @_transparent
    private mutating func emitDOCTYPE() {
        self.sink.process(.doctype(self.currentDOCTYPE.clone()))
    }

    private mutating func consumeCharRef(inAttr isInAttr: Bool, input: inout BufferQueue) {
        var charRefTokenizer = CharRefTokenizer(inAttr: isInAttr)
        repeat {
            switch charRefTokenizer.step(tokenizer: &self, input: &input) {
            case .continue: continue
            case .doneChars(let c1, let c2): self.processCharRef(c1, c2)
            case .doneChar(let c): self.processCharRef(c)
            }
            break
        } while true
    }
}

extension Tokenizer: Sendable where Sink: Sendable {}
