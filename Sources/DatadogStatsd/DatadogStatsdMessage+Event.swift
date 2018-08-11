import struct Foundation.Date

public struct DatadogStatsdEventMessage: DatadogStatsdMessage {
    
    public typealias Param = DatadogStatsdEventMessageParam
    public typealias Params = Set<DatadogStatsdEventMessageParam>
    
    let title: String
    let text: String
    var params: Params

    init(title: String, text: String, params: Params = []) {
        self.title = title
        self.text = text
        self.params = params
    }

    func content() throws -> String {
        let escapedTitle = DatadogStatsdMessageHelper.escapeEventTitle(title)
        let escapedText = DatadogStatsdMessageHelper.escapeEventText(text)

        var string = "_e{\(escapedTitle.count),\(escapedText.count)}:\(escapedTitle)\(DatadogStatsdMessageHelper.PIPE)\(escapedText)"

        for param in params.sorted(by: { $0.hashValue < $1.hashValue }) {
            switch param {
            case .dateHappened(let dateHappened):
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(Int(dateHappened.timeIntervalSince1970))")
            case .hostname(let hostname):
                let value = DatadogStatsdMessageHelper.removePipes(hostname)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(value)")
            case .aggregationKey(let aggregationKey):
                let value = DatadogStatsdMessageHelper.removePipes(aggregationKey)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(value)")
            case .priority(let priority):
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(priority.rawValue)")
            case .sourceTypeName(let sourceTypeName):
                let value = DatadogStatsdMessageHelper.removePipes(sourceTypeName)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(value)")
            case .alertType(let alertType):
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(alertType.rawValue)")
            case .tags(let tags):
                if let tagsString = DatadogStatsdMessageHelper.tagsAsString(tags) {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)#\(tagsString)")
                }
            }
        }

        guard string.utf8.count <= 8 * 1024 else {
            throw DatadogStatsdMessageErrors.toContentFailed("Event \(title) payload is too big (more that 8KB), event discarded")
        }

        return string
    }

    mutating func updateParams(with newParam: Param) {
        self.params.update(with: newParam)
    }

    mutating func appendTagsParamValues(contentsOf newValues: DatadogStatsdMessageTags) {
        guard !newValues.isEmpty else {
            return
        }

        self.params.forEach({ param in
            if case .tags(var tags) = param {
                tags.formUnion(newValues)
                self.updateParams(with: .tags(tags))
                return
            }
        })

        self.updateParams(with: .tags(newValues))
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

public enum DatadogStatsdEventMessageParam: DatadogStatsdMessageParam {
    case dateHappened(Date)
    case hostname(String)
    case aggregationKey(String)
    case priority(DatadogStatsdEventMessagePriority)
    case sourceTypeName(String)
    case alertType(DatadogStatsdEventMessageAlertType)
    case tags(DatadogStatsdMessageTags)

    #if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        switch self {
        case .date_happened:
            1.hash(into: &hasher)
        case .hostname:
            2.hash(into: &hasher)
        case .aggregation_key:
            3.hash(into: &hasher)
        case .priority:
            4.hash(into: &hasher)
        case .source_type_name:
            5.hash(into: &hasher)
        case .alert_type:
            6.hash(into: &hasher)
        case .tags:
            99.hash(into: &hasher)
        }
    }
    #else
    public var hashValue: Int {
        switch self {
        case .dateHappened:
            return 1.hashValue
        case .hostname:
            return 2.hashValue
        case .aggregationKey:
            return 3.hashValue
        case .priority:
            return 4.hashValue
        case .sourceTypeName:
            return 5.hashValue
        case .alertType:
            return 6.hashValue
        case .tags:
            return 99.hashValue
        }
    }
    #endif

    func shorthand() -> String {
        switch self {
        case .dateHappened:
            return "d"
        case .hostname:
            return "h"
        case .aggregationKey:
            return "k"
        case .priority:
            return "p"
        case .sourceTypeName:
            return "s"
        case .alertType:
            return "t"
        default:
            fatalError("no shorthand")
        }
    }
}
