extension Optional where Wrapped: ~Copyable {
    @inlinable
    mutating func take() -> Self {
        let value = consume self
        self = nil
        return consume value
    }
}
