// TODO: Consider to use enum or protocol
public enum Token {
    case char(Character)
    case tag(String)
    case comment(String)
    case eof
    case error(ParseError)
}

// TODO: Consider to use ExpressibleByExtendedGraphemeClusterLiteral or ExpressibleByUnicodeScalarLiteral
extension Token: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Character) {
        self = .char(value)
    }
}