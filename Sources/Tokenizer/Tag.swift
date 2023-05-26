public struct Tag {
    public var name: String
    public var kind: TagKind
    public var attributes: [Attribute]

    public init(name: String, kind: TagKind, attributes: [Attribute] = []) {
        self.name = name
        self.kind = kind
        self.attributes = attributes
    }
}

extension Tag: Equatable {}
