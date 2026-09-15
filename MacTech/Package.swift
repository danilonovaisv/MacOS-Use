// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacTech",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "MacTech", targets: ["MacTech"])],
    targets: [
        .target(name: "MacTechCore"),
        .executableTarget(name: "MacTech", dependencies: ["MacTechCore"]),
        .testTarget(name: "MacTechCoreTests", dependencies: ["MacTechCore"])
    ]
)
