//
//  VH.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct VH<T> {
    let value: T
    let hash: String?
    let time: Date?

    init(_ value: T, hash: String?, time: Date? = Date()) {
        self.value = value
        self.hash = hash
        self.time = time
    }

    enum CodingKeys: String, CodingKey {
        case value = "v"
        case hash = "h"
        case time = "t"
    }

    @inlinable func withValue<U>(_ other: U) -> VH<U> {
        VH<U>(other, hash: hash, time: time)
    }

    @inlinable func mapValue<U>(_ transform: (T) -> U) -> VH<U> {
        withValue(transform(value))
    }
}

extension VH: Encodable where T: Encodable {}

extension VH: Decodable where T: Decodable {}
