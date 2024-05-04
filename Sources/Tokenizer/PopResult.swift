enum PopResult: ~Copyable {
    case known(Unicode.Scalar)
    case others(ArraySlice<Unicode.Scalar>)
}
