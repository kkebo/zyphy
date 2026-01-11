import Str

func lowerASCIIOrNil(_ c: consuming Char) -> Char? {
    switch c {
    case "A"..."Z": .init(.init(UInt8(c.value) &+ 0x20))
    case "a"..."z": c
    case _: nil
    }
}

func lowerASCII(_ c: consuming Char) -> Char {
    switch c {
    case "A"..."Z": .init(.init(UInt8(c.value) &+ 0x20))
    case let c: c
    }
}
