import struct Foundation.Date

public struct DatadogStatsdEventMessage: DatadogStatsdMessage {
    
    public typealias Params = DatadogStatsdEventMessageParams

    let title: String
    let text: String
    var params: Params?

    init(title: String, text: String, params: Params? = nil) {
        self.title = title
        self.text = text
        self.params = params
    }

    func content() throws -> String {
        let escapedTitle = DatadogStatsdMessageHelper.escapeEventTitle(title)
        let escapedText = DatadogStatsdMessageHelper.escapeEventText(text)

        var string = "_e{\(escapedTitle.count),\(escapedText.count)}:\(escapedTitle)\(DatadogStatsdMessageHelper.PIPE)\(escapedText)"

        if let params = params {
            if let dateHappened = params.dateHappened {
                let value = Int(dateHappened.timeIntervalSince1970)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.dateHappened):\(value)")
            }
            if let hostname = params.hostname {
                let value = DatadogStatsdMessageHelper.removePipes(hostname)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.hostname):\(value)")
            }
            if let aggregationKey = params.aggregationKey {
                let value = DatadogStatsdMessageHelper.removePipes(aggregationKey)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.aggregationKey):\(value)")
            }
            if let priority = params.priority {
                let value = priority.rawValue
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.priority):\(value)")
            }
            if let sourceTypeName = params.sourceTypeName {
                let value = DatadogStatsdMessageHelper.removePipes(sourceTypeName)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.sourceTypeName):\(value)")
            }
            if let alertType = params.alertType {
                let value = alertType.rawValue
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(DatadogStatsdEventMessageParamShorthandKey.alertType):\(value)")
            }
            if let tags = params.tags {
                if let value = DatadogStatsdMessageHelper.tagsAsString(tags) {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)#\(value)")
                }
            }
        }

        guard string.utf8.count <= 8 * 1024 else {
            throw DatadogStatsdErrors.getMessageContentFailed("Event \(title) payload is too big (more that 8KB), event discarded")
        }

        return string
    }
}

public enum DatadogStatsdEventMessagePriority: String {
    case normal = "normal"
    case low = "low"
}

public enum DatadogStatsdEventMessageAlertType: String {
    case error = "error"
    case warning = "warning"
    case info = "info"
    case success = "success"
}

public struct DatadogStatsdEventMessageParams: DatadogStatsdMessageParams {
    let dateHappened: Date?
    let hostname: String?
    let aggregationKey: String?
    let priority: DatadogStatsdEventMessagePriority?
    let sourceTypeName: String?
    let alertType: DatadogStatsdEventMessageAlertType?
    var tags: DatadogStatsdMessageTags?

    public init(
        dateHappened: Date? = nil,
        hostname: String? = nil,
        aggregationKey: String? = nil,
        priority: DatadogStatsdEventMessagePriority? = nil,
        sourceTypeName: String? = nil,
        alertType: DatadogStatsdEventMessageAlertType? = nil,
        tags: DatadogStatsdMessageTags? = nil
    ) {
        self.dateHappened = dateHappened
        self.hostname = hostname
        self.aggregationKey = aggregationKey
        self.priority = priority
        self.sourceTypeName = sourceTypeName
        self.alertType = alertType
        self.tags = tags
    }
}

enum DatadogStatsdEventMessageParamShorthandKey: String {
    case dateHappened = "d"
    case hostname = "h"
    case aggregationKey = "k"
    case priority = "p"
    case sourceTypeName = "s"
    case alertType = "t"
}
