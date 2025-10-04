public enum QuirksMode: BitwiseCopyable, Equatable, Hashable, Sendable {
    case quirks
    case limited
    case no
}

public protocol TreeSink<Handle>: ~Copyable {
    associatedtype Handle

    var document: Handle { get }
    func parseError(_ error: consuming ParseError)
    mutating func insert(_ node: consuming Node)
    func setQuirksMode(_ mode: consuming QuirksMode)
}
