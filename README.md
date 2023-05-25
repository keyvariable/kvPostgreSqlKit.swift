# kvPostgreSqlKit.swift

![Swift 5.2](https://img.shields.io/badge/swift-5.2-green.svg)
![Linux](https://img.shields.io/badge/os-linux-green.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg)
![iOS](https://img.shields.io/badge/os-iOS-green.svg)

A lightweight wrapper for [PostgresClientKit](https://github.com/codewinsdotcom/PostgresClientKit) Swift package.


## Supported Platforms

The same as [PostgresClientKit](https://github.com/codewinsdotcom/PostgresClientKit).


## Getting Started

### Swift Tools 5.2+

#### Package Dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/keyvariable/kvPostgreSqlKit.swift.git", from: "0.2.0"),
]
```

#### Target Dependencies:

```swift
dependencies: [
    .product(name: "kvPostgreSqlKit", package: "kvPostgreSqlKit.swift"),
]
```

### Xcode

Documentation: [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).


## Authors

- Svyatoslav Popov ([@sdpopov-keyvariable](https://github.com/sdpopov-keyvariable), [info@keyvar.com](mailto:info@keyvar.com)).
