// TODO: Consider to use enum or protocol
public enum Token {
    case char(Character)
    case tag(Tag)
    case comment(String)
    case eof
    case error(ParseError)
}

extension Token: Equatable {}

// TODO: Consider to use ExpressibleByExtendedGraphemeClusterLiteral or ExpressibleByUnicodeScalarLiteral
extension Token: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Character) {
        self = .char(value)
    }
}
