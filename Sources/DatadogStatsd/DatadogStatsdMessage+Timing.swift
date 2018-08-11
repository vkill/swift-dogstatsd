public struct DatadogStatsdTimingMessage: DatadogStatsdMetricMessage, DatadogStatsdMessage {

    public typealias Param = DatadogStatsdMetricMessageParam
    public typealias Params = DatadogStatsdMetricMessageParams
    
    var name: String
    var delta: Int
    var type: DatadogStatsdMetricMessageType
    var params: Params

    init(name: String, delta: Int, params: Params = []) {
        self.name = name
        self.delta = delta
        self.type = .timing
        self.params = params
    }

    func deltaAsString() -> String {
        return "\(delta)"
    }
}
