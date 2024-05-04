public enum Token: Equatable, Sendable {
    case char(Unicode.Scalar)
    case chars(ArraySlice<Unicode.Scalar>)
    case tag(Tag)
    case comment(String)
    case doctype(DOCTYPE)
    case eof
    case error(ParseError)
}
