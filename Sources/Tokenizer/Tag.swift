public struct Tag: Equatable, Sendable {
    public var name: String
    public var kind: TagKind
    public var attrs: [String: String]
    public var selfClosing: Bool

    public init(
        name: consuming String,
        kind: consuming TagKind,
        attrs: consuming [String: String] = [:],
        selfClosing: Bool = false
    ) {
        self.name = name
        self.kind = kind
        self.attrs = attrs
        self.selfClosing = selfClosing
    }
}
