public struct Document: ~Copyable, Sendable {
    public var title: String
    public var body: Optional<Node>
    public var head: Optional<Node>
}
