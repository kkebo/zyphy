public struct Tag {
    public var name: String
    public var kind: TagKind
    public var attrs: [Attribute]
    public var selfClosing: Bool

    public init(
        name: __owned String,
        kind: __owned TagKind,
        attrs: __owned [Attribute] = [],
        selfClosing: __owned Bool = false
    ) {
        self.name = consume name
        self.kind = consume kind
        self.attrs = consume attrs
        self.selfClosing = consume selfClosing
    }
}

extension Tag: Equatable {}
