public struct DatadogStatsdSetMessage: DatadogStatsdMetricMessage, DatadogStatsdMessage {

    public typealias Param = DatadogStatsdMetricMessageParam
    public typealias Params = DatadogStatsdMetricMessageParams
    
    var name: String
    var delta: Double
    var type: DatadogStatsdMetricMessageType
    var params: Params

    init(name: String, delta: Double, params: Params = []) {
        self.name = name
        self.delta = delta
        self.type = .set
        self.params = params
    }

    func deltaAsString() -> String {
        return "\(delta)"
    }
}
