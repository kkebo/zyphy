public struct DOCTYPE: Equatable, Sendable {
    public var name: Optional<String>
    public var publicID: Optional<String>
    public var systemID: Optional<String>
    public var forceQuirks: Bool

    public init(
        name: consuming String? = nil,
        publicID: consuming String? = nil,
        systemID: consuming String? = nil,
        forceQuirks: Bool = false
    ) {
        self.name = name
        self.publicID = publicID
        self.systemID = systemID
        self.forceQuirks = forceQuirks
    }
}
