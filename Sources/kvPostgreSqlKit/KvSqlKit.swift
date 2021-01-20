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
//  KvSqlKit.swift
//  kvPostreSqlKit
//
//  Created by Svyatoslav Popov on 10.05.2020.
//

import Foundation
import kvSqlKit



// MARK: - KvPostgreSQL.Statement

extension KvPostgreSQL.Statement {

    @inlinable
    public convenience init(_ query: KvSqlQuery, in db: KvPostgreSQL) throws {
        try self.init(query.sql, in: db)
    }

}



// MARK: - KvPostgreSQL

extension KvPostgreSQL {

    @inlinable
    public func prepared(_ query: KvSqlQuery) throws -> Statement {
        try prepared(query.sql)
    }



    @inlinable
    public func prepared(_ query: KvSqlQuery, with completion: @escaping (Result<Statement, Error>) -> Void) {
        prepared(query.sql, with: completion)
    }

}



// MARK: - KvSqlQuery

extension KvSqlQuery {

    @inlinable
    public func prepare(in postgreSQL: KvPostgreSQL) throws -> KvPostgreSQL.Statement {
        try postgreSQL.prepared(self)
    }



    @inlinable
    public func prepared(in postgreSQL: KvPostgreSQL, with completion: @escaping (Result<KvPostgreSQL.Statement, Error>) -> Void) {
        postgreSQL.prepared(self, with: completion)
    }

}
