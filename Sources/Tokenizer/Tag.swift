public import Str

public struct Tag: Equatable, Sendable {
    public var name: Str
    public var kind: TagKind
    public var attrs: [Str: Str]
    public var selfClosing: Bool

    public init(
        name: consuming Str,
        kind: consuming TagKind,
        attrs: consuming [Str: Str] = [:],
        selfClosing: Bool = false
    ) {
        self.name = name
        self.kind = kind
        self.attrs = attrs
        self.selfClosing = selfClosing
    }
}
