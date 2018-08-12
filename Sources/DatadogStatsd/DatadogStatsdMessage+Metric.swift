public struct DatadogStatsdMetricMessage: DatadogStatsdMessage {

    public typealias Params = DatadogStatsdMetricMessageParams

    let name: String
    let delta: DatadogStatsdMetricMessageDelta
    let type: DatadogStatsdMetricMessageType
    var params: Params?

    init(name: String, delta: DatadogStatsdMetricMessageDelta, type: DatadogStatsdMetricMessageType, params: Params? = nil) {
        self.name = name
        self.delta = delta
        self.type = type
        self.params = params
    }

    func content() throws -> String {
        let escapedName = DatadogStatsdMessageHelper.escapeMetricName(name)

        var string = "\(escapedName):\(self.deltaAsString())\(DatadogStatsdMessageHelper.PIPE)\(type.rawValue)"

        if let params = params {
            if let sampleRate = params.sampleRate {
                guard sampleRate == 1 || DatadogStatsdMessageHelper.rand() < sampleRate else {
                    return ""
                }

                if sampleRate < 1 {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)@\(sampleRate)")
                }
            }

            if let tags = params.tags {
                if let value = DatadogStatsdMessageHelper.tagsAsString(tags) {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)#\(value)")
                }
            }
        }

        return string
    }

    private func deltaAsString() -> String {
        switch delta {
        case let value as Int:
            return "\(value)"
        case let value as Double:
            // return String(format: "%g", value)
            return "\(value)"
        default:
            fatalError()
        }
    }
}

public protocol DatadogStatsdMetricMessageDelta {}
extension Int: DatadogStatsdMetricMessageDelta {}
extension Double: DatadogStatsdMetricMessageDelta {}

enum DatadogStatsdMetricMessageType: String {
    case count        = "c"
    case distribution = "d"
    case gauge        = "g"
    case histogram    = "h"
    case set          = "s"
    case timing       = "ms"
}

public struct DatadogStatsdMetricMessageParams: DatadogStatsdMessageParams {
    let sampleRate: Double?
    var tags: DatadogStatsdMessageTags?

    public init(
        sampleRate: Double? = nil,
        tags: DatadogStatsdMessageTags? = nil
    ) {
        if let sampleRate = sampleRate {
            assert((0.0...1.0).contains(sampleRate), "sampleRate require to be in range 0.0...1.0")
        }
        self.sampleRate = sampleRate
        self.tags = tags
    }

    public static func sampleRate(_ value: Double) -> DatadogStatsdMetricMessageParams {
        return self.init(sampleRate: value)
    }
}
