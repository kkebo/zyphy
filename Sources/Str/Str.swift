public typealias StrSlice = ArraySlice<Char>
public typealias Char = Unicode.Scalar

public struct Str: Hashable, Sendable {
    @usableFromInline
    var storage: ContiguousArray<Char>

    @inline(always)
    @export(implementation)
    public init() {
        self.storage = []
    }

    @inline(always)
    @export(implementation)
    public init(_ char: Char) {
        self.storage = [char]
    }

    @inline(always)
    @export(implementation)
    public init(_ chars: ContiguousArray<Char>) {
        self.storage = chars
    }

    @inline(always)
    @export(implementation)
    public init(_ sequence: some Sequence<Self.Element>) {
        self.storage = .init(sequence)
    }

    @inline(always)
    @export(implementation)
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inline(always)
    @export(implementation)
    public mutating func append(_ newElement: Self.Element) {
        self.storage.append(newElement)
    }

    @inline(always)
    @export(implementation)
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.storage += rhs.storage
    }

    @inline(always)
    @export(implementation)
    public static func += (lhs: inout Self, rhs: some Sequence<Self.Element>) {
        lhs.storage += rhs
    }
}

extension Str: Sequence {
    public typealias Iterator = ContiguousArray<Char>.Iterator
    public typealias Element = Char

    @inline(always)
    @export(implementation)
    public func makeIterator() -> Self.Iterator { self.storage.makeIterator() }
}

extension Str: BidirectionalCollection {
    public typealias Index = ContiguousArray<Char>.Index
    public typealias Indices = ContiguousArray<Char>.Indices
    public typealias SubSequence = ContiguousArray<Char>.SubSequence

    @inline(always)
    @export(implementation)
    public var startIndex: Self.Index { self.storage.startIndex }
    @inline(always)
    @export(implementation)
    public var endIndex: Self.Index { self.storage.endIndex }
    @inline(always)
    @export(implementation)
    public var indices: Self.Indices { self.storage.indices }
    @inline(always)
    @export(implementation)
    public func index(before i: Self.Index) -> Self.Index { self.storage.index(before: i) }
    @inline(always)
    @export(implementation)
    public func index(after i: Self.Index) -> Self.Index { self.storage.index(after: i) }

    @inline(always)
    @export(implementation)
    public var count: Int { self.storage.count }
    @inline(always)
    @export(implementation)
    public var isEmpty: Bool { self.storage.isEmpty }

    @inline(always)
    @export(implementation)
    public subscript(position: Self.Index) -> Self.Element {
        self.storage[position]
    }
    @inline(always)
    @export(implementation)
    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        self.storage[bounds]
    }
}

extension Str: ExpressibleByStringLiteral {
    @inline(always)
    @export(implementation)
    public init(stringLiteral value: consuming String) {
        guard !value.isEmpty else {
            self.init()
            return
        }
        self.init(value.unicodeScalars)
    }
}

extension Str: ExpressibleByUnicodeScalarLiteral {
    @inline(always)
    @export(implementation)
    public init(unicodeScalarLiteral value: consuming Unicode.Scalar) {
        self.storage = [value]
    }
}

extension Str: ExpressibleByExtendedGraphemeClusterLiteral {
    @inline(always)
    @export(implementation)
    public init(extendedGraphemeClusterLiteral value: consuming Character) {
        self.init(value.unicodeScalars)
    }
}

extension Str: ExpressibleByStringInterpolation {}

extension StrSlice: @retroactive ExpressibleByStringLiteral {
    @inline(always)
    @export(implementation)
    public init(stringLiteral value: consuming String) {
        guard !value.isEmpty else {
            self = []
            return
        }
        self.init(value.unicodeScalars)
    }
}

extension StrSlice: @retroactive ExpressibleByUnicodeScalarLiteral {
    @inline(always)
    @export(implementation)
    public init(unicodeScalarLiteral value: consuming Unicode.Scalar) {
        self = [value]
    }
}

extension StrSlice: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {
    @inline(always)
    @export(implementation)
    public init(extendedGraphemeClusterLiteral value: consuming Character) {
        self.init(value.unicodeScalars)
    }
}

extension StrSlice: @retroactive ExpressibleByStringInterpolation {}
