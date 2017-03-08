import PackageDescription

let package = Package(
    name: "Walllpaper",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/BrettRToomey/Jobs.git", majorVersion: 0),
    ],
    exclude: [
        "Database",
        "Localization",
    ]
)
