public protocol TokenSink {
    mutating func process(_ token: consuming Token)
}
