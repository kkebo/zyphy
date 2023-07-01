public struct Tokenizer<Sink: TokenSink>: ~Copyable {
    public var sink: Sink
    var state: State
    var reconsumeChar: Optional<Character>
    var charRefTokenizer: Optional<CharRefTokenizer>
    var currentTagName: String
    var currentTagKind: TagKind
    var currentAttrName: String
    var currentAttrValue: String
    var currentAttrs: [Attribute]
    var currentComment: String
    var currentDOCTYPE: DOCTYPE

    public init(sink: __owned Sink) {
        self.sink = consume sink
        self.state = .data
        self.reconsumeChar = nil
        self.charRefTokenizer = nil
        self.currentTagName = ""
        self.currentTagKind = .start
        self.currentAttrName = ""
        self.currentAttrValue = ""
        self.currentAttrs = []
        self.currentComment = ""
        self.currentDOCTYPE = .init()
    }

    // TODO: Consider input type
    public mutating func tokenize(_ input: inout String.Iterator) {
        loop: while true {
            self.charRefTokenizer?.tokenize(&input)

            switch self.state {
            case .data: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .tagOpen); continue loop
                case "\0": self.go(error: .unexpectedNull, emit: "\0")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rcdata: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .rcdataLessThanSign); continue loop
                case "\0": self.go(error: .unexpectedNull, emit: "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rawtext: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .rawtextLessThanSign); continue loop
                case "\0": self.go(error: .unexpectedNull, emit: "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .scriptData: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .scriptDatalessThanSign); continue loop
                case "\0": self.go(error: .unexpectedNull, emit: "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .plaintext: while true {
                switch self.getChar(from: &input) {
                case "\0": self.go(error: .unexpectedNull, emit: "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .tagOpen: while true {
                switch self.getChar(from: &input) {
                case "!": self.go(to: .markupDeclarationOpen); continue loop
                case "/": self.go(to: .endTagOpen); continue loop
                case "?": self.go(error: .unexpectedQuestionMark, createCommentWith: "?", to: .bogusComment); continue loop
                case nil: self.go(error: .eofBeforeTagName, emit: "<", .eof); break loop
                case let c? where c.isASCII && c.isLetter: self.go(createStartTagWith: c.lowercased(), to: .tagName); continue loop
                case let c?: self.go(error: .invalidFirstChar, emit: "<", reconsume: c, to: .data); continue loop
                }
            }
            case .endTagOpen: while true {
                switch self.getChar(from: &input) {
                case ">": self.go(error: .missingEndTagName, to: .data); continue loop
                case "\0": self.go(error: .invalidFirstChar, .unexpectedNull, createCommentWith: "\u{FFFD}", to: .bogusComment); continue loop
                case nil: self.go(error: .eofBeforeTagName, emit: "<", "/", .eof); break loop
                case let c? where c.isASCII && c.isLetter: self.go(createEndTagWith: c.lowercased(), to: .tagName); continue loop
                case let c?: self.go(error: .invalidFirstChar, createCommentWith: c, to: .bogusComment); continue loop
                }
            }
            case .tagName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case "\0": self.go(error: .unexpectedNull, appendTagName: "\u{FFFD}")
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendTagName(c.lowercased())
                case let c?: self.appendTagName(c)
                }
            }
            case .rcdataLessThanSign: while true {
                switch self.getChar(from: &input) {
                case "/":
                    // TODO: Set the temporary buffer to the empty string
                    self.go(to: .rcdataEndTagOpen); continue loop
                case nil: self.emit("<", .eof); break loop
                case let c?: self.go(emit: "<", reconsume: c, to: .rcdata); continue loop
                }
            }
            case .rcdataEndTagOpen: while true {
                switch self.getChar(from: &input) {
                case let c? where c.isASCII && c.isLetter: self.go(createEndTagWith: c, to: .rcdataEndTagName); continue loop
                case nil: self.emit("<", "/", .eof); break loop
                case let c?: self.go(emit: "<", "/", reconsume: c, to: .rcdata); continue loop
                }
            }
            case .rcdataEndTagName: while true {
                // FIXME: Implement
                preconditionFailure("Not implemented")
            }
            case .beforeAttributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case "=": self.go(error: .unexpectedEqualsSign, createAttrWith: "=", to: .attributeName); continue loop
                case "\0": self.go(error: .unexpectedNull, createAttrWith: "\u{FFFD}", to: .attributeName); continue loop
                case "\"": self.go(error: .unexpectedCharInAttrName, createAttrWith: "\"", to: .attributeName); continue loop
                case "'": self.go(error: .unexpectedCharInAttrName, createAttrWith: "'", to: .attributeName); continue loop
                case "<": self.go(error: .unexpectedCharInAttrName, createAttrWith: "<", to: .attributeName); continue loop
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.go(createAttrWith: c.lowercased(), to: .attributeName); continue loop
                case let c?: self.go(createAttrWith: c, to: .attributeName); continue loop
                }
            }
            case .attributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case "=": self.go(to: .beforeAttributeValue); continue loop
                case "\0": self.go(error: .unexpectedNull, appendAttrName: "\u{FFFD}")
                case "\"": self.go(error: .unexpectedCharInAttrName, appendAttrName: "\"")
                case "'": self.go(error: .unexpectedCharInAttrName, appendAttrName: "'")
                case "<": self.go(error: .unexpectedCharInAttrName, appendAttrName: "<")
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendAttrName(c.lowercased())
                case let c?: self.appendAttrName(c)
                }
            }
            case .afterAttributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case "=": self.go(to: .beforeAttributeValue); continue loop
                case "\0": self.go(error: .unexpectedNull, createAttrWith: "\u{FFFD}", to: .attributeName); continue loop
                case "\"": self.go(error: .unexpectedCharInAttrName, createAttrWith: "\"", to: .attributeName); continue loop
                case "'": self.go(error: .unexpectedCharInAttrName, createAttrWith: "'", to: .attributeName); continue loop
                case "<": self.go(error: .unexpectedCharInAttrName, createAttrWith: "<", to: .attributeName); continue loop
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.go(createAttrWith: c.lowercased(), to: .attributeName); continue loop
                case let c?: self.go(createAttrWith: c, to: .attributeName); continue loop
                }
            }
            case .beforeAttributeValue: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\"": self.go(to: .attributeValueDoubleQuoted); continue loop
                case "'": self.go(to: .attributeValueSingleQuoted); continue loop
                case ">": self.go(error: .missingAttrValue, emitTagTo: .data); continue loop
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c?: self.go(reconsume: c, to: .attributeValueUnquoted); continue loop
                }
            }
            case .attributeValueDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case "\"": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0": self.go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case "'": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0": self.go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueUnquoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "&": self.consumeCharRef(); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case "\0": self.go(error: .unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case "\"": self.go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "'": self.go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "'")
                case "<": self.go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "=": self.go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "`": self.go(error: .unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case let c?: self.appendAttrValue(c)
                }
            }
            case .afterAttributeValueQuoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.goEmitTag(to: .data); continue loop
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c?: self.go(error: .missingSpaceBetweenAttrs, reconsume: c, to: .beforeAttributeName); continue loop
                }
            }
            case .selfClosingStartTag: while true {
                switch self.getChar(from: &input) {
                case ">": self.goEmitSelfClosingTag(to: .data); continue loop
                case nil: self.go(error: .eofInTag, emit: .eof); break loop
                case let c?: self.go(error: .unexpectedSolidus, reconsume: c, to: .beforeAttributeName); continue loop
                }
            }
            case .bogusComment: while true {
                switch self.getChar(from: &input) {
                case ">": self.goEmitComment(to: .data); continue loop
                case "\0": self.go(error: .unexpectedNull, appendComment: "\u{FFFD}")
                case nil: self.emitCommentAndEOF(); break loop
                case let c?: self.appendComment(c)
                }
            }
            case .markupDeclarationOpen: while true {
                if self.startsExact(&input, with: "--") == true {
                    self.goClearComment(to: .commentStart); continue loop
                } else if self.starts(&input, with: "doctype") == true {
                    self.go(to: .doctype); continue loop
                } else if self.startsExact(&input, with: "[CDATA[") == true {
                    if false {
                        // TODO: If there is an adjusted current node and it is not an element in the HTML namespace, then switch to the CDATA section state.
                        self.go(to: .cdataSection); continue loop
                    } else {
                        self.go(error: .cdataInHTML, createCommentWith: "[CDATA[", to: .bogusComment); continue loop
                    }
                } else {
                    self.go(error: .incorrectlyOpenedComment, clearCommentTo: .bogusComment); continue loop
                }
            }
            case .doctype: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeDOCTYPEName); continue loop
                case ">": self.go(reconsume: ">", to: .beforeDOCTYPEName); continue loop
                case nil: self.emitError(.eofInDOCTYPE); self.emitNewForceQuirksDOCTYPEAndEOF(); break loop
                case let c?: self.go(error: .missingSpaceBeforeDOCTYPEName, reconsume: c, to: .beforeDOCTYPEName); continue loop
                }
            }
            case .beforeDOCTYPEName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\0": self.go(error: .unexpectedNull, createDOCTYPEWith: "\u{FFFD}", to: .doctypeName); continue loop
                case ">": self.go(error: .missingDOCTYPEName, emitNewForceQuirksDOCTYPETo: .data); continue loop
                case nil: self.emitError(.eofInDOCTYPE); self.emitNewForceQuirksDOCTYPEAndEOF(); break loop
                case let c? where c.isASCII && c.isUppercase: self.go(createDOCTYPEWith: c.lowercased(), to: .doctypeName); continue loop
                case let c?: self.go(createDOCTYPEWith: c, to: .doctypeName); continue loop
                }
            }
            case .doctypeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .afterDOCTYPEName); continue loop
                case ">": self.goEmitDOCTYPE(to: .data); continue loop
                case "\0": self.go(error: .unexpectedNull, appendDOCTYPEName: "\u{FFFD}")
                case nil: self.emitError(.eofInDOCTYPE); self.emitForceQuirksDOCTYPEAndEOF(); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendDOCTYPEName(c.lowercased())
                case let c?: self.appendDOCTYPEName(c)
                }
            }
            case .afterDOCTYPEName: while true {
                if self.starts(&input, with: "public") == true {
                    self.go(to: .afterDOCTYPEPublicKeyword); continue loop
                } else if self.starts(&input, with: "system") == true {
                    self.go(to: .afterDOCTYPESystemKeyword); continue loop
                } else {
                    switch self.getChar(from: &input) {
                    case "\t", "\n", "\u{0C}", " ": break
                    case ">": self.goEmitDOCTYPE(to: .data); continue loop
                    case "\0": self.go(error: .invalidCharSequence, .unexpectedNull, forceQuirksTo: .bogusDOCTYPE); continue loop
                    case nil: self.emitError(.eofInDOCTYPE); self.emitForceQuirksDOCTYPEAndEOF(); break loop
                    case _: self.go(error: .invalidCharSequence, forceQuirksTo: .bogusDOCTYPE); continue loop
                    }
                }
            }
            case .afterDOCTYPEPublicKeyword: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeDOCTYPEPublicIdentifier); continue loop
                case "\"":
                    self.emitError(.missingSpaceAfterDOCTYPEPublicKeyword)
                    // TODO: Set the current DOCTYPE token's public identifier to the empty string (not missing)
                    self.go(to: .doctypePublicIdentifierDoubleQuoted); continue loop
                case "'":
                    self.emitError(.missingSpaceAfterDOCTYPEPublicKeyword)
                    // TODO: Set the current DOCTYPE token's public identifier to the empty string (not missing)
                    self.go(to: .doctypePublicIdentifierSingleQuoted); continue loop
                case ">": self.go(error: .missingDOCTYPEPublicID, emitForceQuirksDOCTYPETo: .data); continue loop
                case nil: self.emitError(.eofInDOCTYPE); self.emitForceQuirksDOCTYPEAndEOF(); break loop
                case "\0": self.go(error: .missingQuoteBeforeDOCTYPEPublicID, .unexpectedNull, forceQuirksTo: .bogusDOCTYPE); continue loop
                case _: self.go(error: .missingQuoteBeforeDOCTYPEPublicID, forceQuirksTo: .bogusDOCTYPE); continue loop
                }
            }
            case .beforeDOCTYPEPublicIdentifier: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\"":
                    // TODO: Set the current DOCTYPE token's public identifier to the empty string (not missing)
                    self.go(to: .doctypePublicIdentifierDoubleQuoted); continue loop
                case "'":
                    // TODO: Set the current DOCTYPE token's public identifier to the empty string (not missing)
                    self.go(to: .doctypePublicIdentifierSingleQuoted); continue loop
                case ">": self.go(error: .missingDOCTYPEPublicID, emitForceQuirksDOCTYPETo: .data); continue loop
                case nil: self.emitError(.eofInDOCTYPE); self.emitForceQuirksDOCTYPEAndEOF(); break loop
                case "\0": self.go(error: .missingQuoteBeforeDOCTYPEPublicID, .unexpectedNull, forceQuirksTo: .bogusDOCTYPE); continue loop
                case _: self.go(error: .missingQuoteBeforeDOCTYPEPublicID, forceQuirksTo: .bogusDOCTYPE); continue loop
                }
            }
            case .doctypePublicIdentifierDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypePublicIdentifierSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPEPublicIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .betweenDOCTYPEPublicAndSystemIdentifiers: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPESystemKeyword: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .beforeDOCTYPESystemIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypeSystemIdentifierDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypeSystemIdentifierSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPESystemIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .bogusDOCTYPE: while true {
                switch self.getChar(from: &input) {
                case ">": self.goEmitDOCTYPE(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull)
                case nil: self.emitDOCTYPEAndEOF(); break loop
                case _: break
                }
            }
            case _:
                preconditionFailure("Not implemented")
            }
        }
    }

    @inline(__always)
    private mutating func getChar(from input: inout String.Iterator) -> Character? {
        if let reconsumeChar {
            self.reconsumeChar = nil
            return reconsumeChar
        } else {
            return input.next()
        }
    }

    private mutating func startsExact(
        _ input: inout String.Iterator,
        with pattern: __owned some StringProtocol
    ) -> Bool? {
        let initial = input
        for pc in consume pattern {
            guard let c = input.next() else {
                input = consume initial
                return nil
            }
            guard consume c == consume pc else {
                input = consume initial
                return false
            }
        }
        return true
    }

    private mutating func starts(
        _ input: inout String.Iterator,
        with pattern: __owned some StringProtocol
    ) -> Bool? {
        let initial = input
        for pc in consume pattern {
            guard let c = input.next() else {
                input = consume initial
                return nil
            }
            guard c.lowercased() == pc.lowercased() else {
                input = consume initial
                return false
            }
        }
        return true
    }

    @inline(__always)
    private mutating func go(to state: __owned State) {
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, to state: __owned State) {
        self.sink.process(.error(consume error))
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(reconsume c: __owned Character, to state: __owned State) {
        self.reconsumeChar = consume c
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        emit char: __owned Character,
        reconsume c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.sink.process(.char(consume char))
        self.reconsumeChar = consume c
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        emit char: __owned Character,
        reconsume c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.char(consume char))
        self.reconsumeChar = consume c
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        emit char1: __owned Character,
        _ char2: __owned Character,
        reconsume c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.char(consume char1))
        self.sink.process(.char(consume char2))
        self.reconsumeChar = consume c
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        reconsume c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.reconsumeChar = consume c
        self.state = consume state
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenizer = .init()
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        clearCommentTo state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentComment = ""
        self.state = consume state
    }

    @inline(__always)
    private mutating func goClearComment(to state: __owned State) {
        self.currentComment = ""
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error error1: __owned ParseError,
        _ error2: __owned ParseError,
        createCommentWith c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error1))
        self.sink.process(.error(consume error2))
        self.currentComment = String(consume c)
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        createCommentWith c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentComment = String(consume c)
        self.state = consume state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        createCommentWith s: __owned String,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentComment = consume s
        self.state = consume state
    }

    @inline(__always)
    private mutating func appendComment(_ c: __owned Character) {
        self.currentComment.append(consume c)
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, appendComment c: __owned Character) {
        self.sink.process(.error(consume error))
        self.currentComment.append(consume c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(createStartTagWith s: __owned String, to state: __owned State) {
        self.currentTagName = consume s
        self.currentTagKind = .start
        self.currentAttrs.removeAll()
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(createEndTagWith c: __owned Character, to state: __owned State) {
        self.currentTagName = String(consume c)
        self.currentTagKind = .end
        self.currentAttrs.removeAll()
        self.state = consume state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(createEndTagWith s: __owned String, to state: __owned State) {
        self.currentTagName = consume s
        self.currentTagKind = .end
        self.currentAttrs.removeAll()
        self.state = consume state
    }

    @inline(__always)
    private mutating func appendTagName(_ c: __owned Character) {
        self.currentTagName.append(consume c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendTagName(_ s: __owned String) {
        self.currentTagName.append(consume s)
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, appendTagName c: __owned Character) {
        self.sink.process(.error(consume error))
        self.currentTagName.append(consume c)
    }

    @inline(__always)
    private mutating func go(createAttrWith c: __owned Character, to state: __owned State) {
        self.pushAttr()
        self.currentAttrName = String(consume c)
        self.state = consume state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(createAttrWith s: __owned String, to state: __owned State) {
        self.pushAttr()
        self.currentAttrName = consume s
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        createAttrWith c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.pushAttr()
        self.currentAttrName = String(consume c)
        self.state = consume state
    }

    @inline(__always)
    private mutating func appendAttrName(_ c: __owned Character) {
        self.currentAttrName.append(consume c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendAttrName(_ s: __owned String) {
        self.currentAttrName.append(consume s)
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        appendAttrName c: __owned Character
    ) {
        self.sink.process(.error(consume error))
        self.currentAttrName.append(consume c)
    }

    @inline(__always)
    private mutating func appendAttrValue(_ c: __owned Character) {
        self.currentAttrValue.append(consume c)
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        appendAttrValue c: __owned Character
    ) {
        self.sink.process(.error(consume error))
        self.currentAttrValue.append(consume c)
    }

    @inline(__always)
    private mutating func pushAttr() {
        guard !self.currentAttrName.isEmpty else { return }
        self.currentAttrs.append(.init(name: self.currentAttrName, value: self.currentAttrValue))
        self.currentAttrName.removeAll()
        self.currentAttrValue.removeAll()
    }

    @inline(__always)
    private mutating func createDOCTYPE() {
        self.currentDOCTYPE = .init()
    }

    @inline(__always)
    private mutating func go(
        createDOCTYPEWith c: __owned Character,
        to state: __owned State
    ) {
        self.currentDOCTYPE = .init(name: String(consume c))
        self.state = consume state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(
        createDOCTYPEWith s: __owned String,
        to state: __owned State
    ) {
        self.currentDOCTYPE = .init(name: consume s)
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        createDOCTYPEWith c: __owned Character,
        to state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentDOCTYPE = .init(name: String(consume c))
        self.state = consume state
    }

    @inline(__always)
    private mutating func appendDOCTYPEName(_ c: __owned Character) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(consume c)
        case .none: self.currentDOCTYPE.name = String(consume c)
        }
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendDOCTYPEName(_ s: __owned String) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(consume s)
        case .none: self.currentDOCTYPE.name = consume s
        }
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        appendDOCTYPEName c: __owned Character
    ) {
        self.sink.process(.error(consume error))
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(consume c)
        case .none: self.currentDOCTYPE.name = String(consume c)
        }
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        forceQuirksTo state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentDOCTYPE.forceQuirks = true
        self.state = consume state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(
        error error1: __owned ParseError,
        _ error2: __owned ParseError,
        forceQuirksTo state: __owned State
    ) {
        self.sink.process(.error(consume error1))
        self.sink.process(.error(consume error2))
        self.currentDOCTYPE.forceQuirks = true
        self.state = consume state
    }

    @inline(__always)
    private mutating func emitError(_ error: __owned ParseError) {
        self.sink.process(.error(consume error))
    }

    @inline(__always)
    private mutating func emitEOF() {
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emit(_ c: __owned Character) {
        self.sink.process(.char(consume c))
    }

    @inline(__always)
    private mutating func emit(_ c: __owned Character, _ token: __owned Token) {
        self.sink.process(.char(consume c))
        self.sink.process(consume token)
    }

    @inline(__always)
    private mutating func emit(
        _ c1: __owned Character,
        _ c2: __owned Character,
        _ token: __owned Token
    ) {
        self.sink.process(.char(consume c1))
        self.sink.process(.char(consume c2))
        self.sink.process(consume token)
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, emit char: __owned Character) {
        self.sink.process(.error(consume error))
        self.sink.process(.char(consume char))
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, emit char1: __owned Character, _ char2: __owned Character) {
        self.sink.process(.error(consume error))
        self.sink.process(.char(consume char1))
        self.sink.process(.char(consume char2))
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(error: __owned ParseError, emit char: __owned Character, _ token: __owned Token) {
        self.sink.process(.error(consume error))
        self.sink.process(.char(consume char))
        self.sink.process(consume token)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        emit char1: __owned Character,
        _ char2: __owned Character,
        _ token: __owned Token
    ) {
        self.sink.process(.error(consume error))
        self.sink.process(.char(consume char1))
        self.sink.process(.char(consume char2))
        self.sink.process(consume token)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func go(error: __owned ParseError, emit token: __owned Token) {
        self.sink.process(.error(consume error))
        self.sink.process(consume token)
    }

    @inline(__always)
    private mutating func goEmitTag(to state: __owned State) {
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: false
                )
            )
        )
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(error: __owned ParseError, emitTagTo state: __owned State) {
        self.sink.process(.error(consume error))
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: false
                )
            )
        )
        self.state = consume state
    }

    @inline(__always)
    private mutating func goEmitSelfClosingTag(to state: __owned State) {
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: true
                )
            )
        )
        self.state = consume state
    }

    @inline(__always)
    private mutating func goEmitComment(to state: __owned State) {
        self.sink.process(.comment(self.currentComment))
        self.state = consume state
    }

    @inline(__always)
    private mutating func emitCommentAndEOF() {
        self.sink.process(.comment(self.currentComment))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func goEmitDOCTYPE(to state: __owned State) {
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        emitForceQuirksDOCTYPETo state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.currentDOCTYPE.forceQuirks = true
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.state = consume state
    }

    @inline(__always)
    private mutating func go(
        error: __owned ParseError,
        emitNewForceQuirksDOCTYPETo state: __owned State
    ) {
        self.sink.process(.error(consume error))
        self.sink.process(.doctype(.init(forceQuirks: true)))
        self.state = consume state
    }

    @inline(__always)
    private mutating func emitDOCTYPEAndEOF() {
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emitForceQuirksDOCTYPEAndEOF() {
        self.currentDOCTYPE.forceQuirks = true
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emitNewForceQuirksDOCTYPEAndEOF() {
        self.sink.process(.doctype(.init(forceQuirks: true)))
        self.sink.process(.eof)
    }
}

#if TESTING_ENABLED
    import Foundation
    import PlaygroundTester

    struct TestSink {
        var tokens = [Token]()
    }

    extension TestSink: TokenSink {
        mutating func process(_ token: __owned Token) {
            self.tokens.append(consume token)
        }
    }

    @objcMembers
    final class TokenizerTests: TestCase {
        func testTokenizeBasicHTML() {
            let html = #"""
            <!DOCTYPE html>
            <html lang="en">
            <head>
            <meta charset="UTF-8" />
            <title>title</title>
            </head>
            <body>
            hi
            </body>
            </html>
            """#

            let sink = TestSink()
            var tokenizer = Tokenizer(sink: consume sink)
            var iter = html.makeIterator()
            tokenizer.tokenize(&iter)

            let tokens: [Token] = [
                .doctype(.init(name: "html")),
                "\n",
                .tag(
                    Tag(
                        name: "html",
                        kind: .start,
                        attrs: [.init(name: "lang", value: "en")]
                    )
                ),
                "\n",
                .tag(Tag(name: "head", kind: .start)),
                "\n",
                .tag(
                    Tag(
                        name: "meta",
                        kind: .start,
                        attrs: [.init(name: "charset", value: "UTF-8")],
                        selfClosing: true
                    )
                ),
                "\n",
                .tag(Tag(name: "title", kind: .start)),
                "t",
                "i",
                "t",
                "l",
                "e",
                .tag(Tag(name: "title", kind: .end)),
                "\n",
                .tag(Tag(name: "head", kind: .end)),
                "\n",
                .tag(Tag(name: "body", kind: .start)),
                "\n",
                "h",
                "i",
                "\n",
                .tag(Tag(name: "body", kind: .end)),
                "\n",
                .tag(Tag(name: "html", kind: .end)),
                .eof,
            ]
            AssertEqual(tokens, other: tokenizer.sink.tokens)
        }
    }
#endif
