public struct Attribute: Equatable {
    public var name: String
    public var value: String

    public init(name: consuming String, value: consuming String) {
        self.name = consume name
        self.value = consume value
    }
}
