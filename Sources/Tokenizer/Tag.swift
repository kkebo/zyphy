public struct Tag: Equatable {
    public var name: String
    public var kind: TagKind
    public var attrs: [Attribute]
    public var selfClosing: Bool

    public init(
        name: consuming String,
        kind: consuming TagKind,
        attrs: consuming [Attribute] = [],
        selfClosing: consuming Bool = false
    ) {
        self.name = consume name
        self.kind = consume kind
        self.attrs = consume attrs
        self.selfClosing = consume selfClosing
    }
}
