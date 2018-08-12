protocol DatadogStatsdMessage {
    associatedtype Params: DatadogStatsdMessageParams
    var params: Params? { get set }

    func content() throws -> String
}

//
public typealias DatadogStatsdMessageTags = Set<String>

//
protocol DatadogStatsdMessageParams: Hashable {
    var tags: DatadogStatsdMessageTags? { get set }
}
