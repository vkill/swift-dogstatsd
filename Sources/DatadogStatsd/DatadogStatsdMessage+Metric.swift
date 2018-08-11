protocol DatadogStatsdMetricMessage {
    associatedtype Delta

    var name: String { get }
    var delta: Delta { get }
    var type: DatadogStatsdMetricMessageType { get }

    typealias Param = DatadogStatsdMetricMessageParam
    typealias Params = DatadogStatsdMetricMessageParams
    var params: Params { get set }

    func deltaAsString() -> String
}

extension DatadogStatsdMetricMessage {
    func content() throws -> String {
        let escapedName = DatadogStatsdMessageHelper.escapeMetricName(name)

        var string = "\(escapedName):\(self.deltaAsString())\(DatadogStatsdMessageHelper.PIPE)\(type.rawValue)"

        for param in params.sorted(by: { $0.hashValue < $1.hashValue }) {
            switch param {
            case .sampleRate(let sampleRate):
                DatadogStatsdMessageHelper.assertMetricSampleRate(sampleRate)

                guard sampleRate == 1 || DatadogStatsdMessageHelper.rand() < sampleRate else {
                    return ""
                }

                if sampleRate != 1 {
                    string.append(contentsOf: "\(DatadogStatsdMessageHelper.PIPE)@\(sampleRate)")
                }
            case .prefix(let prefix):
                string.insert(contentsOf: "\(prefix)", at: string.startIndex)
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

enum DatadogStatsdMetricMessageType: String {
    case count        = "c"
    case distribution = "d"
    case gauge        = "g"
    case histogram    = "h"
    case set          = "s"
    case timing       = "ms"
}

public enum DatadogStatsdMetricMessageParam: DatadogStatsdMessageParam {
    case sampleRate(Double)
    case prefix(String)
    case tags(DatadogStatsdMessageTags)

    #if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        switch self {
        case .sampleRate:
            1.hash(into: &hasher)
        case .prefix:
            2.hash(into: &hasher)
        case .tags:
            99.hash(into: &hasher)
        }
    }
    #else
    public var hashValue: Int {
        switch self {
        case .sampleRate:
            return 1.hashValue
        case .prefix:
            return 2.hashValue
        case .tags:
            return 99.hashValue
        }
    }
    #endif
}

public typealias DatadogStatsdMetricMessageParams = Set<DatadogStatsdMetricMessageParam>
