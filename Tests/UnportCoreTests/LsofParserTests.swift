import Testing
@testable import UnportCore

@Suite struct LsofParserTests {
    @Test func parsesProcessesAndPorts() {
        let output = """
        p501
        cnode
        Litalo
        f23
        n*:3000
        p777
        cpostgres
        Litalo
        f7
        n127.0.0.1:5432
        """

        #expect(LsofParser.parse(output) == [
            ListeningPort(port: 3000, pid: 501, command: "node", user: "italo"),
            ListeningPort(port: 5432, pid: 777, command: "postgres", user: "italo"),
        ])
    }

    @Test func deduplicatesIPv4AndIPv6Sockets() {
        let output = "p501\ncnode\nLitalo\nf23\nn*:3000\nf24\nn[::1]:3000\n"

        #expect(LsofParser.parse(output).map(\.port) == [3000])
    }

    @Test func keepsDistinctPortsOfSameProcess() {
        let output = "p501\ncnode\nLitalo\nf23\nn*:3000\nf24\nn*:9229\n"

        #expect(LsofParser.parse(output).map(\.port) == [3000, 9229])
    }

    @Test func unescapesCommandNames() {
        let output = "p42\ncCode\\x20Helper\nLitalo\nf1\nn*:8080\n"

        #expect(LsofParser.parse(output).first?.command == "Code Helper")
    }

    @Test func emptyOutputYieldsNoPorts() {
        #expect(LsofParser.parse("").isEmpty)
    }

    @Test func matchesByPortCommandOrPid() {
        let port = ListeningPort(port: 3000, pid: 501, command: "node", user: "italo")

        #expect(port.matches(""))
        #expect(port.matches("300"))
        #expect(port.matches("NOD"))
        #expect(port.matches("501"))
        #expect(!port.matches("8080"))
    }
}
