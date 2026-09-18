import AppKit
import UnportCore

@MainActor
final class PortStore: ObservableObject {
    @Published private(set) var ports: [ListeningPort] = []
    @Published private(set) var errorMessage: String?
    @Published var query = ""

    var filteredPorts: [ListeningPort] {
        ports.filter { $0.matches(query) }
    }

    func refresh() async {
        do {
            ports = try await Task.detached(priority: .userInitiated) {
                try PortScanner.scan()
            }.value
        } catch {
            errorMessage = "Could not list ports: \(error.localizedDescription)"
        }
    }

    func open(_ port: ListeningPort) {
        guard let url = URL(string: "http://localhost:\(port.port)") else { return }
        NSWorkspace.shared.open(url)
    }

    func copy(_ port: ListeningPort) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("localhost:\(port.port)", forType: .string)
    }

    /// Asks the process to quit, then forces it if it is still holding the port.
    func kill(_ port: ListeningPort) async {
        errorMessage = nil
        guard Darwin.kill(port.pid, SIGTERM) == 0 else {
            errorMessage = "Could not kill \(port.command) (\(port.pid)): \(String(cString: strerror(errno)))"
            return
        }

        try? await Task.sleep(for: .milliseconds(300))
        await refresh()

        guard ports.contains(port) else { return }
        try? await Task.sleep(for: .seconds(1))
        await refresh()

        // Only escalate when the same pid still owns the same port, so a recycled pid is never hit.
        if ports.contains(port) {
            _ = Darwin.kill(port.pid, SIGKILL)
            try? await Task.sleep(for: .milliseconds(300))
            await refresh()
        }
    }
}
