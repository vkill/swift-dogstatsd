protocol DatadogStatsdMessage {
    associatedtype Params: DatadogStatsdMessageParams
    var params: Params? { get set }

    func content() throws -> String
}

//
public typealias DatadogStatsdMessageTags = Set<String>

//
protocol DatadogStatsdMessageParams {
    var tags: DatadogStatsdMessageTags? { get set }
}
