@inline(__always)
@inlinable
func lowerASCIIOrNil(_ c: consuming Unicode.Scalar) -> Unicode.Scalar? {
    switch c {
    case let c where "A"..."Z" ~= c: .init(.init(UInt8(c.value) &+ 0x20))
    case let c where "a"..."z" ~= c: c
    case _: nil
    }
}

@inline(__always)
@inlinable
func lowerASCII(_ c: consuming Unicode.Scalar) -> Unicode.Scalar {
    switch c {
    case let c where "A"..."Z" ~= c: .init(.init(UInt8(c.value) &+ 0x20))
    case let c: c
    }
}
