public struct Tag: Equatable, Sendable {
    public var name: String
    public var kind: TagKind
    public var attrs: [String: String]
    public var selfClosing: Bool

    public init(
        name: consuming String,
        kind: consuming TagKind,
        attrs: consuming [String: String] = [:],
        selfClosing: consuming Bool = false
    ) {
        self.name = consume name
        self.kind = consume kind
        self.attrs = consume attrs
        self.selfClosing = consume selfClosing
    }
}
