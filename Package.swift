// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NestedPaging",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "NestedPaging", targets: ["NestedPaging"]),
    ],
    targets: [
        .target(
            name: "NestedPaging",
            path: "Sources/NestedPaging"
        ),
    ]
)
