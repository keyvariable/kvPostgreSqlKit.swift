// swift-tools-version:5.2
//
//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//
//  SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription


let targets: [Target] = [
    .target(name: "kvPostgreSqlKit",
            dependencies: [
                .product(name: "kvSqlKit", package: "kvSqlKit-Swift"),
                "PostgresClientKit"
            ]),
    .testTarget(name: "kvPostgreSqlKitTests", dependencies: [ "kvPostgreSqlKit" ]),
]

let package = Package(
    name: "kvPostgreSqlKit.swift",
    platforms: [ .iOS(.v11), ],
    products: [
        .library(name: "kvPostgreSqlKit", targets: [ "kvPostgreSqlKit" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", from: "1.4.3"),
        .package(url: "https://github.com/keyvariable/kvSqlKit-Swift.git", from: "0.1.1"),
    ],
    targets: targets
)
