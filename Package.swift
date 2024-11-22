// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TypeInferedFactory",
    platforms: [.macOS(.v10_15), .iOS(.v15)],
    products: [
        .library(
            name: "TypeInferedFactory",
            targets: ["TypeInferedFactory"]
        ),
        .executable(
            name: "TypeInferedFactoryClient",
            targets: ["TypeInferedFactoryClient"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "600.0.0-latest"
        ),
        .package(
            url: "https://github.com/Swinject/Swinject.git",
            from: "2.9.1"
        ),
    ],
    targets: [
        .target(
            name: "TypeInferedFactoryCore",
            dependencies: [],
            path: "Sources/TypeInferedFactoryCore"
        ),
        .macro(
            name: "TypeInferedFactoryMacros",
            dependencies: [
                "TypeInferedFactoryCore",
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ],
            path: "Sources/TypeInferedFactoryMacros"
        ),
        .target(
            name: "TypeInferedFactory",
            dependencies: [
                "TypeInferedFactoryMacros",
                "TypeInferedFactoryCore",
            ],
            path: "Sources/TypeInferedFactory"
        ),
        .executableTarget(
            name: "TypeInferedFactoryClient",
            dependencies: [
                "TypeInferedFactory",
                "Swinject",
            ],
            path: "Sources/TypeInferedFactoryClient"
        ),
        .testTarget(
            name: "TypeInferedFactoryTests",
            dependencies: [
                "TypeInferedFactoryCore",
                "TypeInferedFactoryMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/TypeInferedFactoryTests"
        ),
    ]
)
