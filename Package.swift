// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeeplinkTestHelper",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "DeeplinkTestHelper", targets: ["DeeplinkTestHelper"]),
    ],
    targets: [
        .target(
            name: "DeeplinkTestHelper"
        )
    ]
)
