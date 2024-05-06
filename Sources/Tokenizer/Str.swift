public typealias Str = [Char]
public typealias StrSlice = ArraySlice<Char>
public typealias Char = Unicode.Scalar

extension Str {
    static func == (lhs: Self, rhs: String) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs.unicodeScalars) {
            guard l == r else { return false }
        }
        return true
    }
}
