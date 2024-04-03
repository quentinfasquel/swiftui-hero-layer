// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HeroLayerPresentation",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "HeroLayerPresentation",
            targets: ["HeroLayerPresentation"]),
    ],
    targets: [
        .target(
            name: "HeroLayerPresentation"),
    ]
)
