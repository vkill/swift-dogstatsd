import func Foundation.drand48
import func Foundation.srand48
import func Foundation.time

public protocol DatadogStatsdUtils {
    func rand() -> Double
}

struct DatadogStatsdGenericUtils: DatadogStatsdUtils {
    init() {
        #if !swift(>=4.2)
        srand48(Int(time(nil)))
        #endif
    }

    func rand() -> Double {
        #if swift(>=4.2)
        return Double.random(in: 0...1)
        #else
        return drand48()
        #endif
    }
}
