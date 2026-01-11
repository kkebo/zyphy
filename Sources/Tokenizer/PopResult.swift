public import Str

@usableFromInline
enum PopResult: ~Copyable {
    case known(Char)
    case others(StrSlice)
}
