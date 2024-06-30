public typealias Str = [Char]
public typealias StrSlice = ArraySlice<Char>
public typealias Char = Unicode.Scalar

extension Str: @retroactive ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral value: consuming String) {
        guard !value.isEmpty else {
            self = []
            return
        }
        self.init(value.unicodeScalars)
    }
}

extension Str: @retroactive ExpressibleByUnicodeScalarLiteral {
    @inlinable public init(unicodeScalarLiteral value: consuming Unicode.Scalar) {
        self = [value]
    }
}

extension Str: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable public init(extendedGraphemeClusterLiteral value: consuming Character) {
        self.init(value.unicodeScalars)
    }
}

extension Str: @retroactive ExpressibleByStringInterpolation {}
