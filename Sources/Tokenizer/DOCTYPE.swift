public struct DOCTYPE {
    public var name: Optional<String>
    public var forceQuirks: Bool

    public init(
        name: __owned Optional<String> = nil,
        forceQuirks: __owned Bool = false
    ) {
        self.name = _move name
        self.forceQuirks = _move forceQuirks
    }
}

extension DOCTYPE: Equatable {}
