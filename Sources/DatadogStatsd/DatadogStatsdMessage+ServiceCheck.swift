import struct Foundation.Date

public struct DatadogStatsdServiceCheckMessage: DatadogStatsdMessage {

    public typealias Params = DatadogStatsdServiceCheckMessageParams

    let name: String
    let status: DatadogStatsdServiceCheckMessageStatus
    var params: Params?

    init(name: String, status: DatadogStatsdServiceCheckMessageStatus, params: Params? = nil) {
        self.name = name
        self.status = status
        self.params = params
    }

    func content() throws -> String {
        var string = "_sc\(DatadogStatsdMessageHelper.PIPE)\(name)\(DatadogStatsdMessageHelper.PIPE)\(status.rawValue)"

        if let params = params {
            if let timestamp = params.timestamp {
                let value = Int(timestamp.timeIntervalSince1970)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdServiceCheckMessageParamShorthandKey.hostname):\(value)")
            }
            if let hostname = params.hostname {
                let value = DatadogStatsdMessageHelper.removePipes(hostname)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdServiceCheckMessageParamShorthandKey.hostname):\(value)")
            }
            if let message = params.message {
                let value = DatadogStatsdMessageHelper.escapeServiceCheckMessage(message)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdServiceCheckMessageParamShorthandKey.message):\(value)")
            }
            if let tags = params.tags {
                if let value = DatadogStatsdMessageHelper.tagsAsString(tags) {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)#\(value)")
                }
            }
        }

        return string
    }
}

public enum DatadogStatsdServiceCheckMessageStatus: Int {
    case ok       = 0
    case warning  = 1
    case critical = 2
    case unknown  = 3
}

public struct DatadogStatsdServiceCheckMessageParams: DatadogStatsdMessageParams {
    let timestamp: Date?
    let hostname: String?
    let message: String?
    var tags: DatadogStatsdMessageTags?

    public init(
        timestamp: Date? = nil,
        hostname: String? = nil,
        message: String? = nil,
        tags: DatadogStatsdMessageTags? = nil
    ) {
        self.timestamp = timestamp
        self.hostname = hostname
        self.message = message
        self.tags = tags
    }
}

enum DatadogStatsdServiceCheckMessageParamShorthandKey: String {
    case timestamp = "d"
    case hostname = "h"
    case message = "m"
}
