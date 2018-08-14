import struct Foundation.Date

public struct DatadogStatsd {
    private let host: String
    private let port: Int

    private let connection: DatadogStatsdConnection
    private let utils: DatadogStatsdUtils

    private let namespace: String?
    private let tags: DatadogStatsdMessageTags?

    public init(
        host: String = "127.0.0.1",
        port: Int = 8125,
        connection: DatadogStatsdConnection,
        utils: DatadogStatsdUtils? = nil,
        namespace: String? = nil,
        tags: DatadogStatsdMessageTags? = nil
    ) {
        assert((0...65535).contains(port), "port must be in range 0...65535")

        self.host = host
        self.port = port

        self.connection = connection
        if let utils = utils {
            self.utils = utils
        } else {
            self.utils = DatadogStatsdGenericUtils()
        }

        self.namespace = namespace
        self.tags = tags
    }

    //
    public func increment(_ name: String, by value: Int = 1, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.count(name, value, params)
    }

    public func decrement(_ name: String, by value: Int = 1, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.count(name, -value, params)
    }

    public func count(_ name: String, _ count: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, count, .count, params)
    }

    public func gauge(_ name: String, _ value: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .gauge, params)
    }
    public func gauge(_ name: String, _ value: Double, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .gauge, params)
    }

    public func histogram(_ name: String, _ value: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .histogram, params)
    }
    public func histogram(_ name: String, _ value: Double, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .histogram, params)
    }

    public func distribution(_ name: String, _ value: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .distribution, params)
    }
    public func distribution(_ name: String, _ value: Double, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .distribution, params)
    }

    public func timing(_ name: String, _ milliseconds: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        assert(milliseconds >= 0, "milliseconds must be greater than or equal to 0")
        return try self.metric(name, milliseconds, .timing, params)
    }

    public func time(_ name: String, _ params: DatadogStatsdMetricMessage.Params? = nil, task: @escaping () throws -> ()) throws {
        let start = Date()

        do {
            try task()
        }

        let end = Date()
        let ms = Int(((end.timeIntervalSince1970 - start.timeIntervalSince1970) * 1000).rounded(.toNearestOrAwayFromZero))
        return try self.timing(name, ms, params)
    }

    public func set(_ name: String, _ value: Int, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .set, params)
    }
    public func set(_ name: String, _ value: Double, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        return try self.metric(name, value, .set, params)
    }

    private func metric(_ name: String, _ delta: DatadogStatsdMetricMessageDelta, _ type: DatadogStatsdMetricMessageType, _ params: DatadogStatsdMetricMessage.Params? = nil) throws {
        var name = name
        if let namespace = namespace {
            name.insert(contentsOf: namespace, at: name.startIndex)
        }
        var message = DatadogStatsdMetricMessage(name: name, delta: delta, type: type, params: params)
        message.utils = utils
        return try self.sendStat(message)
    }

    //
    public func serviceCheck(_ name: String, _ status: DatadogStatsdServiceCheckMessageStatus, _ params: DatadogStatsdServiceCheckMessage.Params? = nil) throws {
        let message = DatadogStatsdServiceCheckMessage(name: name, status: status, params: params)
        return try self.sendStat(message)
    }

    //
    public func event(_ title: String, _ text: String, _ params: DatadogStatsdEventMessage.Params? = nil) throws {
        let message = DatadogStatsdEventMessage(title: title, text: text, params: params)
        return try self.sendStat(message)
    }

    //
    private func sendStat<T>(_ message: T) throws where T: DatadogStatsdMessage {
        var message = message
        if let tags = tags, tags.count > 0 {
            message.params?.tags?.formUnion(tags)
        }

        let text = try message.content()
        if text.isEmpty {
            return
        }

        // TODO batch
        return try connection.write(text, to: (host, port))
    }
}
