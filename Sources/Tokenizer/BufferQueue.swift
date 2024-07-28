public import DequeModule
public import Str

public struct BufferQueue: ~Copyable, Sendable {
    @usableFromInline
    var buffers: Deque<StrSlice>

    @inlinable
    public init(_ buf: StrSlice) {
        self.buffers = [buf]
    }

    mutating func prepend(_ buf: StrSlice) {
        guard !buf.isEmpty else { return }
        self.buffers.prepend(buf)
    }

    func peek() -> Char? {
        self.buffers.first.flatMap { $0.first }
    }

    mutating func popFirst() -> Char? {
        guard !self.buffers.isEmpty else { return nil }
        defer { if self.buffers[0].isEmpty { self.buffers.removeFirst() } }
        return self.buffers[0].popFirst()
    }

    @inline(__always)
    mutating func pop(except s: consuming SmallCharSet) -> PopResult? {
        guard !self.buffers.isEmpty else { return nil }
        defer { if self.buffers[0].isEmpty { self.buffers.removeFirst() } }
        let count = (self.buffers[0].firstIndex { $0.value < 64 && s.contains($0) } ?? self.buffers[0].endIndex) - self.buffers[0].startIndex
        guard count > 0 else { return self.buffers[0].popFirst().map(PopResult.known) }
        defer { self.buffers[0].removeFirst(count) }
        return .others(self.buffers[0].prefix(count))
    }

    mutating func removeFirst() {
        guard !self.buffers.isEmpty else { return }
        self.buffers[0].removeFirst()
        if self.buffers[0].isEmpty { self.buffers.removeFirst() }
    }
}
