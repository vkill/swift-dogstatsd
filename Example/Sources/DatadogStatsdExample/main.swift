/*
$ brew install socat
$ socat -v udp-recvfrom:8125,fork exec:'/bin/echo'
 */

import NIODatadogStatsd
import DatadogStatsd

let datadogStatsdConnection = NIODatadogStatsdConnection()
_ = try datadogStatsdConnection.bind(
    host: "127.0.0.1",
    port: 29001,
    on: nil
).map { _ in
    let datadogStatsd = DatadogStatsd(
        host: "127.0.0.1",
        port: 8125,
        connection: datadogStatsdConnection
    )
    
    try! datadogStatsd.count("count", 1)
}.wait()
