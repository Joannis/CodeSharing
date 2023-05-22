// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeSharing",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CodeSharing",
            targets: ["CodeSharing"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CodeSharing",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]),
        .target(
            name: "CodeSharingApple",
            dependencies: [
                .target(name: "CodeSharing")
            ]),
        .target(
            name: "CodeSharingVapor",
            dependencies: [
                .target(name: "CodeSharing"),
                .product(name: "Vapor", package: "vapor")
            ]),
        .target(
            name: "CodeSharingMock",
            dependencies: [
                .target(name: "CodeSharing")
            ]),
        .testTarget(
            name: "CodeSharingTests",
            dependencies: ["CodeSharing", "CodeSharingMock", "CodeSharingApple", "CodeSharingVapor", .product(name: "Vapor", package: "vapor"), .product(name: "XCTVapor", package: "vapor")]),
    ]
)
