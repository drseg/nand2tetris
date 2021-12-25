// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nand2Tetris",
    products: [
        .library(
            name: "Nand2Tetris",
            targets: ["Nand2Tetris"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Nand2Tetris",
            dependencies: []),
        .testTarget(
            name: "Nand2TetrisTests",
            dependencies: ["Nand2Tetris"],
            resources: [
                .copy("AcceptanceTests")
            ]
        )
    ]
)
