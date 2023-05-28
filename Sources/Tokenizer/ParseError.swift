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
    case missingEndTagName
    case missingAttrValue
    case missingWhitespaceBetweenAttrs
}

extension ParseError: Error {}
