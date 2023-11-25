@inline(__always)
@inlinable
func lowerASCIIOrNil(_ c: consuming Character) -> Character? {
    let firstScalar = c.firstScalar
    return switch firstScalar {
    case "A"..."Z": .init(.init(UInt8(firstScalar.value) + 0x20))
    case "a"..."z": consume c
    case _: nil
    }
}

@inline(__always)
@inlinable
func lowerASCII(_ c: consuming Character) -> Character {
    let firstScalar = c.firstScalar
    return switch firstScalar {
    case "A"..."Z": .init(.init(UInt8(firstScalar.value) + 0x20))
    case _: consume c
    }
}
