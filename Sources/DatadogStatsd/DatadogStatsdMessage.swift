/*
 https://docs.datadoghq.com/developers/dogstatsd/
 https://docs.datadoghq.com/developers/metrics/
*/

protocol DatadogStatsdMessage {
    associatedtype Param: DatadogStatsdMessageParam
    typealias Params = Set<Param>
    var params: Params { get set }

    func content() throws -> String
    mutating func updateParams(with newParam: Param)
    mutating func appendTagsParamValues(contentsOf newValues: DatadogStatsdMessageTags)
}

//
public protocol DatadogStatsdMessageParam: Hashable {}

//
public typealias DatadogStatsdMessageTags = Set<String>

//
public enum DatadogStatsdMessageErrors: Error {
    case toContentFailed(String)
}
