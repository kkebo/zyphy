public typealias Str = [Char]
public typealias StrSlice = ArraySlice<Char>
public typealias Char = Unicode.Scalar

extension Str: @retroactive ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral value: StringLiteralType) {
        self = .init(value.unicodeScalars)
    }
}

extension Str: @retroactive ExpressibleByUnicodeScalarLiteral {
    @inlinable public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .init(value.unicodeScalars)
    }
}

extension Str: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .init(value.unicodeScalars)
    }
}

extension Str: @retroactive ExpressibleByStringInterpolation {}
