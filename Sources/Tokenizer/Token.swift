public import Str

public enum Token: Equatable, Sendable {
    case char(Char)
    case chars(StrSlice)
    case tag(Tag)
    case comment(Str)
    case doctype(DOCTYPE)
    case eof
    case error(ParseError)
}
