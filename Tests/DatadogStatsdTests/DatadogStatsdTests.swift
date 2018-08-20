import XCTest
@testable import DatadogStatsd

final class DatadogStatsdTests: XCTestCase {
    func testServiceCheck() throws {
        let host = "127.0.0.1"
        let port = 8125
        let conn = Connection(host, port)
        let statsd = DatadogStatsd(host: host, port: port, connection: conn)

        for _ in (1...10) {
            let name = "test"
            guard let status = DatadogStatsdServiceCheckMessageStatus.allCases.randomElement() else {
                fatalError()
            }

            // sends with only name and status
            try statsd.serviceCheck(name, status)
            XCTAssertEqual(conn.recv, ["_sc|\(name)|\(status.rawValue)"])
            conn.cleanRecv()
        }
    }

    static var allTests = [
        ("testServiceCheck", testServiceCheck),
    ]

    class Connection: DatadogStatsdConnection {
        let host: String
        let port: Int
        var recv: [String]

        init(_ host: String, _ port: Int) {
            self.host = host
            self.port = port
            self.recv = []
        }

        func cleanRecv() {
            self.recv = []
        }

        public func write(_ text: String, to: (host: String, port: Int)) throws {
            XCTAssertEqual(to.host, host)
            XCTAssertEqual(to.port, port)
            self.recv.append(text)
        }
    }
}

extension DatadogStatsdServiceCheckMessageStatus {
    static var allCases: [DatadogStatsdServiceCheckMessageStatus] {
        return [.ok, .warning, .critical, .unknown]
    }
}
