// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "csvToJson",
    products: [
        .library(name: "CsvToJson", targets: ["CsvToJson"]),
    ],
    dependencies: [
        .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3"))
    ],
    targets: [
        .target(
            name: "CsvToJson",
            dependencies: ["CSV"]),
    ]
)