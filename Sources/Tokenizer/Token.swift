public enum Token: Equatable, Sendable {
    case char(Char)
    case chars(Str)
    case tag(Tag)
    case comment(String)
    case doctype(DOCTYPE)
    case eof
    case error(ParseError)
}
