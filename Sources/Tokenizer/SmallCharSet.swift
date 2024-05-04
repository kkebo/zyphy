struct SmallCharSet {
    var bits: UInt64

    @inlinable
    func contains(_ c: Unicode.Scalar) -> Bool {
        self.bits & 1 << c.value != 0
    }
}

extension SmallCharSet: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Unicode.Scalar...) {
        self.bits = elements.lazy.map { 1 << $0.value }.reduce(0, |)
    }
}
