// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDNS",
	platforms: [
		.macOS(SupportedPlatform.MacOSVersion.v10_15),
		.iOS(SupportedPlatform.IOSVersion.v13)
	],
    products: [
        .library(
            name: "SwiftDNS",
            targets: ["SwiftDNS"]),
    ],
    targets: [
        .target(
            name: "SwiftDNS",
            dependencies: []),
        .testTarget(
            name: "SwiftDNSTests",
            dependencies: ["SwiftDNS"]),
    ]
)
