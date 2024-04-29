public protocol TokenSink: ~Copyable {
    mutating func process(_ token: consuming Token)
}
