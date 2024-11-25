public enum QuirksMode: BitwiseCopyable, Equatable, Hashable, Sendable {
    case quirks
    case limited
    case no
}

public protocol TreeSink<Handle>: ~Copyable {
    associatedtype Handle

    var document: Handle { get }
    func parseError(msg: consuming String)
    func setQuirksMode(_ mode: consuming QuirksMode)
}
