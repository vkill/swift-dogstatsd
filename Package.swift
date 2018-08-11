// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "DatadogStatsd",
    products: [
        .library(name: "DatadogStatsd", targets: ["DatadogStatsd"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "DatadogStatsd", dependencies: []),
        .testTarget(name: "DatadogStatsdTests", dependencies: ["DatadogStatsd"]),
    ]
)
