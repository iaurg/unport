// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Unport",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "UnportCore"),
        .executableTarget(name: "Unport", dependencies: ["UnportCore"]),
        .executableTarget(name: "IconGenerator", dependencies: ["UnportCore"]),
        .testTarget(name: "UnportCoreTests", dependencies: ["UnportCore"]),
    ]
)
