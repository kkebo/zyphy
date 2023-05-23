public enum ParseError {
    case unexpectedNull
    case unexpectedQuestionMark
    case invalidFirstCharacter
    case eofBeforeTagName
    case eofInTag
    case missingEndTagName
}

extension ParseError: Error {}
