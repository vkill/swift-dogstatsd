// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DatadogStatsdExample",
    dependencies: [
        .package(url: "https://github.com/vkill/swift-dogstatsd.git", .branch("master")),
        .package(url: "https://github.com/vkill/swift-nio-dogstatsd.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "DatadogStatsdExample",
            dependencies: ["DatadogStatsd", "NIODatadogStatsd"]),
    ]
)
