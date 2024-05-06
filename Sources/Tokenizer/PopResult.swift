enum PopResult: ~Copyable {
    case known(Char)
    case others(StrSlice)
}
