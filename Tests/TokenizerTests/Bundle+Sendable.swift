import Foundation

// FIXME: This is a workaround for "error: static property 'module' is not concurrency-safe because non-'Sendable' type 'Bundle' may have shared mutable state"
extension Bundle: @unchecked Sendable {}
