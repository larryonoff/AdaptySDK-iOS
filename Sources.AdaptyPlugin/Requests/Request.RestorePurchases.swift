//
//  Request.RestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct RestorePurchases: AdaptyPluginRequest {
        static let method = "restore_purchases"

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func execute() async throws -> AdaptyJsonData {
            let profile = try await Adapty.restorePurchases()
            return .success(profile)
        }
    }
}

public extension AdaptyPlugin {
    @objc static func restorePurchases(
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(with: completion) { Request.RestorePurchases() }
    }
}
