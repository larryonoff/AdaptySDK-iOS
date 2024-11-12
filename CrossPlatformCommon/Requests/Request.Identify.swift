//
//  Request.Identify.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct Identify: AdaptyPluginRequest {
        static let method = Method.identify

        let customerUserId: String

        enum CodingKeys: String, CodingKey {
            case customerUserId = "customer_user_id"
        }

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                customerUserId: jsonDictionary
                    .value(String.self, forKey: CodingKeys.customerUserId)
            )
        }

        init(customerUserId: String) {
            self.customerUserId = customerUserId
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.identify(customerUserId)
            return .success()
        }
    }
}

public extension AdaptyPlugin {
    @objc static func identify(
        customerUserId: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(with: completion) { Request.Identify(
            customerUserId: customerUserId
        ) }
    }
}