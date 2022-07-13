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
//  KvPostgresClientKit.swift
//  kvPostgreSqlKit
//
//  Created by Svyatoslav Popov on 23.04.2020.
//

import PostgresClientKit



/// Fixed width Int extension
public extension PostgresValue {

    func int<T : FixedWidthInteger>(radix: Int = 10) throws -> T {
        guard let rawValue = rawValue else { throw PostgresError.valueIsNil }
        guard let value = T(rawValue, radix: radix) else { throw PostgresError.valueConversionError(value: self, type: T.self) }

        return value
    }



    func int<T : FixedWidthInteger>(radix: Int = 10) throws -> T? {
        guard let rawValue = rawValue else { return nil }

        return T(rawValue, radix: radix)
    }

}



// Missing extension for Int8.
extension Int8 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for Int16.
extension Int16 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for Int32.
extension Int32 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for Int64.
extension Int64 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for UInt.
extension UInt : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for UInt8.
extension UInt8 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for UInt16.
extension UInt16 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for UInt32.
extension UInt32 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for UInt64.
extension UInt64 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue : PostgresValue { .init(String(describing: self)) }

}



// Missing extension for Float.
extension Float : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue: PostgresValue { .init(String(describing: self)) }

}



#if !os(iOS)
// Missing extension for Float80.
extension Float80 : PostgresValueConvertible {

    /// A `PostgresValue` for the receiver.
    @inlinable
    public var postgresValue: PostgresValue { .init(String(describing: self)) }

}
#endif // !iOS
