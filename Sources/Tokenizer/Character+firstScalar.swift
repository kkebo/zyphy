extension Character {
    // swift-format-ignore: NeverForceUnwrap
    @inline(__always)
    @inlinable
    var firstScalar: Unicode.Scalar { self.unicodeScalars.first! }
}
