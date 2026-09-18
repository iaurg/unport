import Foundation

/// Parses the output of `lsof -F pcLn`, where every line is a single field
/// prefixed by a one-character type: `p` pid, `c` command, `L` user, `n` name.
public enum LsofParser {
    public static func parse(_ output: String) -> [ListeningPort] {
        var pid: Int32?
        var command = ""
        var user = ""
        var seen = Set<String>()
        var ports: [ListeningPort] = []

        for line in output.split(whereSeparator: \.isNewline) {
            guard let field = line.first else { continue }
            let value = String(line.dropFirst())

            switch field {
            case "p":
                pid = Int32(value)
                command = ""
                user = ""
            case "c":
                command = unescape(value)
            case "L":
                user = value
            case "n":
                guard let pid, let port = port(fromName: value) else { continue }
                let entry = ListeningPort(port: port, pid: pid, command: command, user: user)
                // The same socket shows up once per address family (IPv4 + IPv6).
                if seen.insert(entry.id).inserted { ports.append(entry) }
            default:
                continue
            }
        }

        return ports.sorted { ($0.port, $0.pid) < ($1.port, $1.pid) }
    }

    /// Names look like `*:3000`, `127.0.0.1:3000` or `[::1]:3000`.
    static func port(fromName name: String) -> Int? {
        guard let colon = name.lastIndex(of: ":") else { return nil }
        return Int(name[name.index(after: colon)...])
    }

    /// lsof escapes non-printable characters and spaces as `\xHH`.
    static func unescape(_ value: String) -> String {
        guard value.contains("\\x") else { return value }
        var result = ""
        var rest = Substring(value)
        while let range = rest.range(of: "\\x") {
            result += rest[..<range.lowerBound]
            let hex = rest[range.upperBound...].prefix(2)
            if hex.count == 2, let byte = UInt8(hex, radix: 16) {
                result.unicodeScalars.append(Unicode.Scalar(byte))
                rest = rest[range.upperBound...].dropFirst(2)
            } else {
                result += "\\x"
                rest = rest[range.upperBound...]
            }
        }
        return result + rest
    }
}
