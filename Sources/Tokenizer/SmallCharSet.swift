public import Str

@usableFromInline
struct SmallCharSet {
    @usableFromInline
    var bits: UInt64

    @inline(always)
    @export(implementation)
    func contains(_ c: Char) -> Bool {
        self.bits & 1 << c.value != 0
    }
}

extension SmallCharSet: ExpressibleByArrayLiteral {
    @usableFromInline
    init(arrayLiteral elements: Char...) {
        self.bits = elements.lazy.map { 1 << $0.value }.reduce(0, |)
    }
}
