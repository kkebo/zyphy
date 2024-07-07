public struct Node: Sendable {
    public var value: NodeValue
    public var childNodes: [Self]
}

public enum NodeValue: Sendable {
    case element(HTMLElement)
    case text(Text)
}
