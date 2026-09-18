import Foundation

public struct ListeningPort: Identifiable, Hashable, Sendable {
    public let port: Int
    public let pid: Int32
    public let command: String
    public let user: String

    public var id: String { "\(pid):\(port)" }

    public init(port: Int, pid: Int32, command: String, user: String) {
        self.port = port
        self.pid = pid
        self.command = command
        self.user = user
    }

    public func matches(_ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespaces)
        if query.isEmpty { return true }
        return String(port).contains(query)
            || command.localizedCaseInsensitiveContains(query)
            || String(pid) == query
    }
}
