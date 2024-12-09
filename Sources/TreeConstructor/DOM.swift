public import Str

public struct DOM: Sendable {
    public var document: Node
}

public struct Node: Sendable {
    public var value: NodeValue
    public var childNodes: [Self]
}

public enum NodeValue: Sendable {
    case document
    case element(HTMLElement)
    case text(Text)
}

public struct HTMLElement: Sendable {
    public var tagName: Str
    public var attributes: [Str: Str]
}

public struct Text: Sendable {
    public var data: Str
}
