public struct Tag {
    public var name: String
    public var kind: TagKind
    public var attrs: [Attribute]
    public var selfClosing: Bool

    public init(
        name: String,
        kind: TagKind,
        attrs: [Attribute] = [],
        selfClosing: Bool = false
    ) {
        self.name = name
        self.kind = kind
        self.attrs = attrs
        self.selfClosing = selfClosing
    }
}

extension Tag: Equatable {}
