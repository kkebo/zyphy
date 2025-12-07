public import Str

public struct DOM: ~Copyable, Sendable {
    public var document: Node

    public init() {
        self.document = .init(value: .document)
    }
}

public struct Node: Equatable, Hashable, Sendable {
    public var value: NodeValue
    public var childNodes: ContiguousArray<Self>

    public init(value: NodeValue, childNodes: ContiguousArray<Self> = []) {
        self.value = value
        self.childNodes = childNodes
    }
}

public enum NodeValue: Equatable, Hashable, Sendable {
    case document
    case element(HTMLElement)
    case text(Text)
}

public struct HTMLElement: Equatable, Hashable, Sendable {
    public var tagName: Str
    public var attributes: [Str: Str]
}

public struct Text: Equatable, Hashable, Sendable {
    public var data: Str
}

extension DOM: TreeSink {
    public func parseError(_ error: consuming ParseError) {}
    public func setQuirksMode(_ mode: consuming QuirksMode) {}
}
