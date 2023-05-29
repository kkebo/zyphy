public enum ParseError {
    case unexpectedNull
    case unexpectedQuestionMark
    case unexpectedEqualsSign
    case unexpectedCharInAttrName
    case unexpectedCharInUnquotedAttrValue
    case unexpectedSolidus
    case invalidFirstChar
    case eofBeforeTagName
    case eofInTag
    case eofInDOCTYPE
    case missingEndTagName
    case missingAttrValue
    case missingWhitespaceBetweenAttrs
    case missingWhitespaceBeforeDOCTYPEName
    case missingDOTYPEName
    case cdataInHTML
    case incorrectlyOpenedComment
}

extension ParseError: Error {}
