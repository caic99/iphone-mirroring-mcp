// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "iphone-mirroring-mcp",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", exact: "0.12.1"),
    ],
    targets: [
        .target(name: "IPhoneMirroringMCPCore", dependencies: [.product(name: "MCP", package: "swift-sdk")]),
        .executableTarget(name: "iphone-mirroring-mcp", dependencies: ["IPhoneMirroringMCPCore", .product(name: "MCP", package: "swift-sdk")]),
        .testTarget(name: "IPhoneMirroringMCPCoreTests", dependencies: ["IPhoneMirroringMCPCore"]),
    ],
    swiftLanguageModes: [.v5]
)
