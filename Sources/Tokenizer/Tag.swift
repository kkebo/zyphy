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

    // For testing
    package init(
        name: consuming String,
        kind: consuming TagKind,
        attrs: consuming [String: String] = [:],
        selfClosing: Bool = false
    ) {
        self.name = Str(name.unicodeScalars)
        self.kind = kind
        var newAttrs: [Str: Str] = [:]
        for (k, v) in attrs {
            newAttrs[Str(k.unicodeScalars)] = Str(v.unicodeScalars)
        }
        self.attrs = newAttrs
        self.selfClosing = selfClosing
    }

}
