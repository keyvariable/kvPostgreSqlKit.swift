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

        queue.name = "KvPostgreSQL Queue"
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

    @available(iOS 13.0.0, macOS 10.15.0, *)
    public func prepared(_ sql: String) async throws -> Statement {
        try await addOperation {
            .init(try self.connection.prepareStatement(text: sql), self)
        }
    }


    @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
    @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
    public func prepared(_ sql: String) throws -> Statement {
        try addOperation({
            .init(try self.connection.prepareStatement(text: sql), self)
        })
    }

    @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
    @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
    public func prepared(_ sql: String, with completion: @escaping (Result<Statement, Error>) -> Void) {
        addOperation({
            .init(try self.connection.prepareStatement(text: sql), self)
        }, completion: completion)
    }


    // MARK: .Statement

    public class Statement {

        public typealias Value = PostgresValueConvertible
        public typealias RowIterator = PostgresClientKit.Cursor

        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        public typealias Result = Swift.Result<RowIterator, Error>

        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
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


        // MARK: Operations

        @available(iOS 13.0.0, macOS 10.15.0, *)
        @discardableResult
        public func execute() async throws -> RowIterator {
            try await db.addOperation {
                try self.underlying.execute()
            }
        }

        @available(iOS 13.0.0, macOS 10.15.0, *)
        @discardableResult
        public func execute(args: [Value?]) async throws -> RowIterator {
            try await db.addOperation {
                try self.underlying.execute(parameterValues: args)
            }
        }

        /// Execute the receiver asynchronously substituting given arguments.
        @available(iOS 13.0.0, macOS 10.15.0, *)
        @discardableResult @inlinable
        public func execute(_ args: Value?...) async throws -> RowIterator {
            try await execute(args: args)
        }


        /// Execute the receiver asynchronously.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        public func execute(with completion: @escaping Completion) {
            db.addOperation({
                try self.underlying.execute()
            }, completion: completion)
        }

        /// Execute the receiver asynchronously substituting given arguments.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        public func execute(args: [Value?], with completion: @escaping Completion) {
            db.addOperation({
                try self.underlying.execute(parameterValues: args)
            }, completion: completion)
        }

        /// Execute the receiver asynchronously substituting given arguments.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        @inlinable
        public func execute(_ args: Value?..., with completion: @escaping Completion) {
            execute(args: args, with: completion)
        }


        /// Execute the receiver synchronously.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        @discardableResult
        public func execute() throws -> RowIterator {
            try db.addOperation({
                try self.underlying.execute()
            })
        }

        /// Execute the receiver synchronously substituting given arguments.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        @discardableResult
        public func execute(args: [Value?]) throws -> RowIterator {
            try db.addOperation({
                try self.underlying.execute(parameterValues: args)
            })
        }

        /// Execute the receiver synchronously substituting given arguments.
        @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
        @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
        @inlinable @discardableResult
        public func execute(_ args: Value?...) throws -> RowIterator {
            try execute(args: args)
        }

    }

}



// MARK: Operation Execution

extension KvPostgreSQL {

    @available(iOS 13.0.0, macOS 10.15.0, *)
    private func addOperation<T>(_ body: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            addOperation(body, completion: continuation.resume(with:))
        }
    }


    private func addOperation<T>(_ body: @escaping () throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
        let block: () -> Void = { completion(.init(catching: body)) }

        queue == .current ? block() : queue.addOperation(block)
    }


    @available(iOS, deprecated: 13.0.0, message: "Use version with async keyword")
    @available(macOS, deprecated: 10.15.0, message: "Use version with async keyword")
    private func addOperation<T>(_ body: @escaping () throws -> T) throws -> T {
        var result: Result<T, Error>!

        let block: () -> Void = {
            result = .init(catching: body)
        }

        if queue == .current {
            block()
        } else {
            queue.addOperations([ BlockOperation(block: block) ], waitUntilFinished: true)
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
