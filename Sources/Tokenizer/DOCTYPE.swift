public import Str

public struct DOCTYPE: Equatable, Sendable {
    public var name: Optional<Str>
    public var publicID: Optional<Str>
    public var systemID: Optional<Str>
    public var forceQuirks: Bool

    public init(
        name: consuming Str? = nil,
        publicID: consuming Str? = nil,
        systemID: consuming Str? = nil,
        forceQuirks: Bool = false
    ) {
        self.name = name
        self.publicID = publicID
        self.systemID = systemID
        self.forceQuirks = forceQuirks
    }

    // For testing
    @_disfavoredOverload
    package init(
        name: consuming String? = nil,
        publicID: consuming String? = nil,
        systemID: consuming String? = nil,
        forceQuirks: Bool = false
    ) {
        self.name = name.map { Str($0.unicodeScalars) }
        self.publicID = publicID.map { Str($0.unicodeScalars) }
        self.systemID = systemID.map { Str($0.unicodeScalars) }
        self.forceQuirks = forceQuirks
    }

}
