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
//  KvPostgreSQL.swift
//  kvPostgreSqlKit
//
//  Created by Svyatoslav Popov on 14.04.2020.
//

import Foundation
import PostgresClientKit



/// A lightweight wrapper for *PostgresClientKit*.
public class KvPostgreSQL {

    public init(with configuration: Configuration) throws {
        connection = try .init(configuration: configuration.connectionConfiguration)
    }



    private let queue: OperationQueue = {
        let queue = OperationQueue()

        queue.name = "DetDB Queue"
        queue.maxConcurrentOperationCount = 1

        return queue
    }()

    private let connection: PostgresClientKit.Connection

}



// MARK: Configuration

extension KvPostgreSQL {

    public struct Configuration {

        public var host: String
        public var port: Int

        public var database: String?

        public var credential: Credential?


        fileprivate var connectionConfiguration: PostgresClientKit.ConnectionConfiguration {
            var result = PostgresClientKit.ConnectionConfiguration()

            result.host = host
            result.port = port

            result.ssl = false

            if let database = database {
                result.database = database
            }

            if let credential = credential {
                result.user = credential.user
                result.credential = credential.password?.connectionCredential ?? .trust
            }

            return result
        }



        public init(host: String = "::1", port: Int = 5432, database: String? = nil, credential: Credential? = nil) {
            self.host = host
            self.port = port
            self.database = database
            self.credential = credential
        }



        // MARK: Credential

        public struct Credential {

            public var user: String
            public var password: Password?



            public init(user: String, password: Password? = nil) {
                self.user = user
                self.password = password
            }



            // MARK: Password

            public enum Password {

                case cleartext(password: String)
                case md5(password: String)



                fileprivate var connectionCredential: PostgresClientKit.Credential {
                    switch self {
                    case .cleartext(let password):
                        return .cleartextPassword(password: password)
                    case .md5(let password):
                        return .md5Password(password: password)
                    }
                }

            }

        }

    }

}



// MARK: Statement

extension KvPostgreSQL {

    public class Statement {

        public typealias Value = PostgresValueConvertible
        public typealias RowIterator = PostgresClientKit.Cursor


        public typealias Result = Swift.Result<RowIterator, Error>
        public typealias Completion = (Result) -> Void



        public private(set) weak var db: KvPostgreSQL!



        public convenience init(_ sql: String, in db: KvPostgreSQL) throws {
            let underlying: PostgresClientKit.Statement = try db.addOperation({
                try db.connection.prepareStatement(text: sql)
            })

            self.init(underlying, db)
        }



        fileprivate init(_ underlying: PostgresClientKit.Statement, _ db: KvPostgreSQL) {
            self.underlying = underlying
            self.db = db
        }



        private let underlying: PostgresClientKit.Statement



        // MARK: Asynchronous Execution

        /// Execute the receiver asynchronously.
        public func execute(with completion: @escaping Completion) {
            db.addOperation({
                try self.underlying.execute()
            }, completion: completion)
        }



        /// Execute the receiver asynchronously substituting given arguments.
        public func execute(args: [Value?], with completion: @escaping Completion) {
            db.addOperation({
                try self.underlying.execute(parameterValues: args)
            }, completion: completion)
        }



        /// Execute the receiver asynchronously substituting given arguments.
        @inlinable
        public func execute(_ args: Value?..., with completion: @escaping Completion) {
            execute(args: args, with: completion)
        }



        // MARK: Synchronous Execution

        /// Execute the receiver synchronously.
        @discardableResult
        public func execute() throws -> RowIterator {
            try db.addOperation({
                try self.underlying.execute()
            })
        }



        /// Execute the receiver synchronously substituting given arguments.
        @discardableResult
        public func execute(args: [Value?]) throws -> RowIterator {
            try db.addOperation({
                try self.underlying.execute(parameterValues: args)
            })
        }



        /// Execute the receiver synchronously substituting given arguments.
        @inlinable @discardableResult
        public func execute(_ args: Value?...) throws -> RowIterator {
            try execute(args: args)
        }

    }



    public func prepared(_ sql: String) throws -> Statement {
        try addOperation({
            .init(try self.connection.prepareStatement(text: sql), self)
        })
    }



    public func prepared(_ sql: String, with completion: @escaping (Result<Statement, Error>) -> Void) {
        addOperation({
            .init(try self.connection.prepareStatement(text: sql), self)
        }, completion: completion)
    }

}



// MARK: Operation Execution

extension KvPostgreSQL {

    private func addOperation<T>(_ body: @escaping () throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
        let main: () -> Void = { completion(.init(catching: body)) }

        if queue == .current {
            main()

        } else {
            queue.addOperation(main)
        }
    }



    private func addOperation<T>(_ body: @escaping () throws -> T) throws -> T {
        var result: Result<T, Error>!

        let main: () -> Void = {
            result = .init(catching: body)
        }

        if queue == .current {
            main()

        } else {
            queue.addOperations([ BlockOperation(block: main) ], waitUntilFinished: true)
        }

        return try result.get()
    }

}



// MARK: Transactions

extension KvPostgreSQL {

    /// Begins transaction just before *body* is executed and commits the transaction when *body* returns *true* or rollbacks the transaction when *body* returns *false*.
    ///
    /// Body is passed with the receiver.
    ///
    /// - Note: Body is executed on the PQSL operation queue hense all queries are executed serially.
    public func transaction(waitUntilFinished: Bool = false, body: @escaping (KvPostgreSQL) -> Bool) {
        let main: () -> Void = {
            do {
                try self.connection.beginTransaction()
            } catch {
                NSLog("Unable to begin transaction with error: \(error)")
            }

            do {
                try body(self) ? self.connection.commitTransaction() : self.connection.rollbackTransaction()
            } catch {
                NSLog("Unable to finish transaction with error: \(error)")
            }
        }

        if queue == .current, waitUntilFinished {
            main()

        } else {
            queue.addOperations([ BlockOperation(block: main) ], waitUntilFinished: waitUntilFinished)
        }
    }



    /// An overload of *transaction* where *body* returns a standard *Result* value. A *.success* value is threated as successful completion of transaction, a *.failure* value is threated as unsuccessful case.
    /// The associated value are ignored.
    ///
    /// Body is passed with the receiver.
    ///
    /// - Note: Body is executed on the PQSL operation queue hense all queries are executed serially.
    @inlinable
    public func transaction<T>(waitUntilFinished: Bool = false, body: @escaping (KvPostgreSQL) -> Result<T, Error>) {
        transaction(waitUntilFinished: waitUntilFinished) { (db) -> Bool in
            switch body(db) {
            case .success:
                return true
            case .failure:
                return false
            }
        }
    }

}
