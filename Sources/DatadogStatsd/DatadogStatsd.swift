import struct Foundation.Date

public struct DatadogStatsd {
    private let host: String
    private let port: Int

    private let connection: DatadogStatsdConnection

    private let namespace: String?
    private let tags: DatadogStatsdMessageTags

    public init(
        host: String = "127.0.0.1",
        port: Int = 8125,
        connection: DatadogStatsdConnection,
        namespace: String? = nil,
        tags: DatadogStatsdMessageTags = []
    ) {
        assert((0...65535).contains(port), "port require to be in range 0...65535")

        self.host = host
        self.port = port

        self.connection = connection

        self.namespace = namespace
        self.tags = tags
    }

    //
    public func increment(_ name: String, by value: Int = 1, params: DatadogStatsdCountMessage.Params = []) throws {
        return try self.count(name, value, params: params)
    }
    public func increment(_ name: String, by value: Int = 1, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.increment(name, by: value, params: [.sampleRate(sampleRate)])
    }

    public func decrement(_ name: String, by value: Int = 1, params: DatadogStatsdCountMessage.Params = []) throws {
        return try self.count(name, -value, params: params)
    }
    public func decrement(_ name: String, by value: Int = 1, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.decrement(name, by: value, params: [.sampleRate(sampleRate)])
    }

    public func count(_ name: String, _ count: Int, params: DatadogStatsdCountMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdCountMessage(name: name, delta: count, params: params))
    }
    public func count(_ name: String, _ count: Int, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.count(name, count, params: [.sampleRate(sampleRate)])
    }

    //
    public func gauge(_ name: String, _ value: Double, params: DatadogStatsdGaugeMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdGaugeMessage(name: name, delta: value, params: params))
    }
    public func gauge(_ name: String, _ value: Double, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.gauge(name, value, params: [.sampleRate(sampleRate)])
    }

    //
    public func histogram(_ name: String, _ value: Double, params: DatadogStatsdHistogramMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdHistogramMessage(name: name, delta: value, params: params))
    }
    public func histogram(_ name: String, _ value: Double, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.histogram(name, value, params: [.sampleRate(sampleRate)])
    }

    //
    public func distribution(_ name: String, _ value: Double, params: DatadogStatsdDistributionMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdDistributionMessage(name: name, delta: value, params: params))
    }
    public func distribution(_ name: String, _ value: Double, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.distribution(name, value, params: [.sampleRate(sampleRate)])
    }

    //
    public func timing(_ name: String, _ ms: Int, params: DatadogStatsdTimingMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdTimingMessage(name: name, delta: ms, params: params))
    }
    public func timing(_ name: String, _ ms: Int, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.timing(name, ms, params: [.sampleRate(sampleRate)])
    }

    public func time(_ name: String, params: DatadogStatsdTimingMessage.Params = [], task: @escaping () throws -> ()) throws {
        let start = Date()

        do {
            try task()
        } catch {
            let end = Date()
            let ms = Int(((end.timeIntervalSince1970 - start.timeIntervalSince1970) * 1000).rounded(.toNearestOrAwayFromZero))
            return try self.timing(name, ms, params: params)
        }

        let end = Date()
        let ms = Int(((end.timeIntervalSince1970 - start.timeIntervalSince1970) * 1000).rounded(.toNearestOrAwayFromZero))
        return try self.timing(name, ms, params: params)
    }
    public func time(_ name: String, sampleRate: Double, task: @escaping () throws -> ()) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.time(name, params: [.sampleRate(sampleRate)], task: task)
    }

    //
    public func set(_ name: String, _ value: Double, params: DatadogStatsdSetMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdSetMessage(name: name, delta: value, params: params))
    }
    public func set(_ name: String, _ value: Double, sampleRate: Double) throws {
        DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)
        return try self.set(name, value, params: [.sampleRate(sampleRate)])
    }

    //
    public func serviceCheck(_ name: String, _ status: DatadogStatsdServiceCheckMessageStatus, params: DatadogStatsdServiceCheckMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdServiceCheckMessage(name: name, status: status, params: params))
    }

    //
    public func event(_ title: String, _ text: String, params: DatadogStatsdEventMessage.Params = []) throws {
        return try self.sendStat(DatadogStatsdEventMessage(title: title, text: text, params: params))
    }

    //
    private func sendStat<T>(_ message: T) throws where T: DatadogStatsdMessage {
        return try self.sendStat0(message)
    }

    private func sendStat<T>(_ message: T) throws where T: DatadogStatsdMetricMessage, T: DatadogStatsdMessage {
        var message = message
        if let namespace = namespace {
            message.updateParams(with: .prefix(namespace))
        }
        return try self.sendStat0(message)
    }

    private func sendStat0<T>(_ message: T) throws where T: DatadogStatsdMessage {
        var message = message
        if tags.count > 0 {
            message.appendTagsParamValues(contentsOf: tags)
        }

        let text = try message.content()
        if text.isEmpty {
            return
        }

        // TODO batch
        return try connection.write(text, to: (host, port))
    }
}
