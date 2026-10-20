// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KeepCat",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "KeepCat", targets: ["KeepCat"])
    ],
    targets: [
        .executableTarget(
            name: "KeepCat",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "KeepCatTests",
            dependencies: ["KeepCat"]
        )
    ],
    swiftLanguageModes: [.v5]
)
