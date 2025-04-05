public typealias StrSlice = ArraySlice<Char>
public typealias Char = Unicode.Scalar

public struct Str: Hashable, Sendable {
    @usableFromInline
    var storage: ContiguousArray<Char>

    @inlinable
    public init() {
        self.storage = []
    }

    @inlinable
    public init(_ char: Char) {
        self.storage = [char]
    }

    @inlinable
    public init(_ chars: ContiguousArray<Char>) {
        self.storage = chars
    }

    @inlinable
    public init(_ sequence: some Sequence<Self.Element>) {
        self.storage = .init(sequence)
    }

    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public mutating func append(_ newElement: Self.Element) {
        self.storage.append(newElement)
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.storage += rhs.storage
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: some Sequence<Self.Element>) {
        lhs.storage += rhs
    }
}

extension Str: Sequence {
    public typealias Iterator = ContiguousArray<Char>.Iterator
    public typealias Element = Char

    @inlinable
    public func makeIterator() -> Self.Iterator { self.storage.makeIterator() }
}

extension Str: BidirectionalCollection {
    public typealias Index = ContiguousArray<Char>.Index
    public typealias Indices = ContiguousArray<Char>.Indices
    public typealias SubSequence = ContiguousArray<Char>.SubSequence

    @inlinable
    public var startIndex: Self.Index { self.storage.startIndex }
    @inlinable
    public var endIndex: Self.Index { self.storage.endIndex }
    @inlinable
    public var indices: Self.Indices { self.storage.indices }
    @inlinable
    public func index(before i: Self.Index) -> Self.Index { self.storage.index(before: i) }
    @inlinable
    public func index(after i: Self.Index) -> Self.Index { self.storage.index(after: i) }

    @inlinable
    public var count: Int { self.storage.count }
    @inlinable
    public var isEmpty: Bool { self.storage.isEmpty }

    @inlinable
    public subscript(position: Self.Index) -> Self.Element {
        self.storage[position]
    }
    @inlinable
    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        self.storage[bounds]
    }
}

extension Str: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: consuming String) {
        guard !value.isEmpty else {
            self.init()
            return
        }
        self.init(value.unicodeScalars)
    }
}

extension Str: ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: consuming Unicode.Scalar) {
        self.storage = [value]
    }
}

extension Str: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable
    public init(extendedGraphemeClusterLiteral value: consuming Character) {
        self.init(value.unicodeScalars)
    }
}

extension Str: ExpressibleByStringInterpolation {}

extension StrSlice: @retroactive ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: consuming String) {
        guard !value.isEmpty else {
            self = []
            return
        }
        self.init(value.unicodeScalars)
    }
}

extension StrSlice: @retroactive ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: consuming Unicode.Scalar) {
        self = [value]
    }
}

extension StrSlice: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable
    public init(extendedGraphemeClusterLiteral value: consuming Character) {
        self.init(value.unicodeScalars)
    }
}

extension StrSlice: @retroactive ExpressibleByStringInterpolation {}
