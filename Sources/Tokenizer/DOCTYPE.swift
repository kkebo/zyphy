public struct DOCTYPE: Equatable, Sendable {
    public var name: Optional<String>
    public var publicID: Optional<String>
    public var systemID: Optional<String>
    public var forceQuirks: Bool

    public init(
        name: consuming String? = nil,
        publicID: consuming String? = nil,
        systemID: consuming String? = nil,
        forceQuirks: consuming Bool = false
    ) {
        self.name = consume name
        self.publicID = consume publicID
        self.systemID = consume systemID
        self.forceQuirks = consume forceQuirks
    }
}
