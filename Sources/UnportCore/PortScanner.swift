import Foundation

public enum PortScanner {
    /// Lists TCP sockets in LISTEN state. Blocking; call off the main thread.
    public static func scan() throws -> [ListeningPort] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        // -nP: skip DNS/service lookups (fast), +c 0: don't truncate command names.
        process.arguments = ["-nP", "+c", "0", "-iTCP", "-sTCP:LISTEN", "-F", "pcLn"]

        let stdout = Pipe()
        process.standardOutput = stdout
        process.standardError = FileHandle.nullDevice

        try process.run()
        // Drain the pipe before waiting, otherwise a full pipe buffer deadlocks lsof.
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        // lsof exits 1 when nothing matches, so the exit status is not an error signal.
        return LsofParser.parse(String(decoding: data, as: UTF8.self))
    }
}
