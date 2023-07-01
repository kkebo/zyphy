public struct Attribute {
    public var name: String
    public var value: String

    public init(name: __owned String, value: __owned String) {
        self.name = consume name
        self.value = consume value
    }
}

extension Attribute: Equatable {}
