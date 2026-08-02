// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "joy-con-codex-controller",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "JoyConCodexCore",
            targets: ["JoyConCodexCore"]
        ),
        .executable(
            name: "JoyConCodexController",
            targets: ["JoyConCodexController"]
        ),
    ],
    targets: [
        .target(
            name: "JoyConCodexCore"
        ),
        .executableTarget(
            name: "JoyConCodexController",
            dependencies: ["JoyConCodexCore"],
            resources: [
                .process("Resources"),
            ],
            linkerSettings: [
                .linkedFramework("ApplicationServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreHaptics"),
                .linkedFramework("GameController"),
                .linkedFramework("IOKit"),
                .linkedFramework("SwiftUI"),
            ]
        ),
        .executableTarget(
            name: "JoyConInputLogger",
            path: "Tools/JoyConInputLogger",
            linkerSettings: [
                .linkedFramework("IOKit"),
            ]
        ),
        .testTarget(
            name: "JoyConCodexCoreTests",
            dependencies: ["JoyConCodexCore"],
            swiftSettings: [
                .unsafeFlags([
                    "-F",
                    "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                ]),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F",
                    "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker",
                    "-rpath",
                    "-Xlinker",
                    "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker",
                    "-rpath",
                    "-Xlinker",
                    "/Library/Developer/CommandLineTools/Library/Developer/usr/lib",
                ]),
                .linkedFramework("Testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
