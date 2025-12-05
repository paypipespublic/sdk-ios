// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayPipes",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PayPipes",
            targets: ["PayPipes"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PayPipes",
            path: "PayPipes.xcframework"
        ),
    ]
)
