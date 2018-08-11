import struct Foundation.Date

public struct DatadogStatsdServiceCheckMessage: DatadogStatsdMessage {

    public typealias Param = DatadogStatsdServiceCheckMessageParam
    public typealias Params = Set<DatadogStatsdServiceCheckMessageParam>

    let name: String
    let status: DatadogStatsdServiceCheckMessageStatus
    var params: Params

    init(name: String, status: DatadogStatsdServiceCheckMessageStatus, params: Params = []) {
        self.name = name
        self.status = status
        self.params = params
    }

    func content() throws -> String {
        var string = "_sc\(DatadogStatsdMessageHelper.PIPE)\(name)\(DatadogStatsdMessageHelper.PIPE)\(status.rawValue)"

        for param in params.sorted(by: { $0.hashValue < $1.hashValue }) {
            switch param {
            case .timestamp(let timestamp):
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(Int(timestamp.timeIntervalSince1970))")
            case .hostname(let hostname):
                let value = DatadogStatsdMessageHelper.removePipes(hostname)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(value)")
            case .message(let message):
                let value = DatadogStatsdMessageHelper.escapeServiceCheckMessage(message)
                string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)\(param.shorthand()):\(value)")
            case .tags(let tags):
                if let tagsString = DatadogStatsdMessageHelper.tagsAsString(tags) {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)#\(tagsString)")
                }
            }
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

public enum DatadogStatsdServiceCheckMessageStatus: Int {
    case ok       = 0
    case warning  = 1
    case critical = 2
    case unknown  = 3
}

public enum DatadogStatsdServiceCheckMessageParam: DatadogStatsdMessageParam {
    case timestamp(Date)
    case hostname(String)
    case message(String)
    case tags(DatadogStatsdMessageTags)

    #if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        switch self {
        case .timestamp:
            1.hash(into: &hasher)
        case .hostname:
            2.hash(into: &hasher)
        case .message:
            3.hash(into: &hasher)
        case .tags:
            99.hash(into: &hasher)
        }
    }
    #else
    public var hashValue: Int {
        switch self {
        case .timestamp:
            return 1.hashValue
        case .hostname:
            return 2.hashValue
        case .message:
            return 3.hashValue
        case .tags:
            return 99.hashValue
        }
    }
    #endif

    func shorthand() -> String {
        switch self {
        case .timestamp:
            return "d"
        case .hostname:
            return "h"
        case .message:
            return "m"
        default:
            fatalError("no shorthand")
        }
    }
}
