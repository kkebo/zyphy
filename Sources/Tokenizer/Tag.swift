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
        self.name = _move name
        self.kind = _move kind
        self.attrs = _move attrs
        self.selfClosing = _move selfClosing
    }
}

extension Tag: Equatable {}
