public struct Attribute {
    public var name: String
    public var value: String

    public init(name: __owned String, value: __owned String) {
        self.name = _move name
        self.value = _move value
    }
}

extension Attribute: Equatable {}
