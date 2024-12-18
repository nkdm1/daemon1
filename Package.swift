// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Cocoa

let package = Package(
    name: "daemon1",
    platforms: [
       .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/tmandry/AXSwift", from: "0.3.0"),
        .package(url: "https://github.com/tmandry/Swindler", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "daemon1",
            dependencies: [
                "AXSwift",
                "Swindler",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources"),
    ]
)

