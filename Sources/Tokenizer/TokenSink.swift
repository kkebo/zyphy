public protocol TokenSink {
    mutating func process(_ token: __owned Token)
}
