extension Optional where Wrapped: ~Copyable {
    @inline(always)
    mutating func take() -> Self {
        let value = consume self
        self = nil
        return consume value
    }
}
