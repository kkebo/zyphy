public import Str

public enum Token: ~Copyable, Sendable {
    case char(Char)
    case chars(StrSlice)
    case tag(Tag)
    case comment(Str)
    case doctype(DOCTYPE)
    case eof
    case error(ParseError)
}
