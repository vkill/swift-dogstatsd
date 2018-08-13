public protocol DatadogStatsdConnection {
    func write(_ text: String, to: (host: String, port: Int)) throws
}

public struct DatadogStatsdPrinterConnection: DatadogStatsdConnection {
    public func write(_ text: String, to: (host: String, port: Int)) throws {
        Swift.print("""
        sending "\(text)" to \(to.host):\(to.port)
        """)
    }
}
