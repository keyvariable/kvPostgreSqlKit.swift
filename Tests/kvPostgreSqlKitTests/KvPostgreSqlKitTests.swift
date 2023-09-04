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
//
//  KvPostgreSqlKitTests.swift
//  kvPostgreSqlKit
//
//  Created by Svyatoslav Popov on 17.04.2020.
//

import XCTest

@testable import kvPostgreSqlKit

import kvSqlKit



final class KvPostgreSqlKitTests : XCTestCase {

    // MARK: - testApplication()

    func testApplication() async throws {
        let db = try KvPostgreSQL(with: dbConfiguraion)

        guard #available(iOS 13.0.0, macOS 10.15.0, *)
        else { return XCTFail("Unexpected OS") }

        let rows = try await db.prepared("SELECT version()").execute()

        try rows.lazy
            .map { try $0.get() }
            .forEach { row in print(row) }
    }



    // MARK: - testSimpleExpression()

    func testSimpleExpression() async throws {
        let db = try KvPostgreSQL(with: dbConfiguraion)

        let arg0 = 1, arg1 = 2.14
        let rows = try await db.prepared(KvSQL.select(%1, %2)).execute(arg0, arg1)

        try rows.lazy
            .map { try $0.get() }
            .forEach { row in
                let answer0 = try row.columns[0].int()
                XCTAssertEqual(answer0, arg0)

                let answer1 = try row.columns[1].double()
                XCTAssertEqual(answer1, arg1)
            }
    }



    // MARK: - Auxiliaries

    private let dbConfiguraion = KvPostgreSQL.Configuration(credential: .init(user: NSUserName()))

}
