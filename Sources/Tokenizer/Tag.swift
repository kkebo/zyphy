public struct Tag {
    public var name: String
    public var kind: TagKind
    public var attrs: [Attribute]

    public init(name: String, kind: TagKind, attrs: [Attribute] = []) {
        self.name = name
        self.kind = kind
        self.attrs = attrs
    }
}

extension Tag: Equatable {}
