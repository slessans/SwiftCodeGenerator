// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftCodeGenerator",
    dependencies: [
      .Package(url: "https://github.com/Carthage/Commandant.git", Version(0, 12, 0)),
    ]
)
