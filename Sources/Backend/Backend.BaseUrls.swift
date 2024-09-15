//
//  Backend.BaseUrls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2023
//

import Foundation

extension Backend {
    struct URLs {
        static let publicEnvironment = URLs(
            baseUrl: URL(string: "https://api.adapty.io/api/v1")!,
            fallbackUrl: URL(string: "https://fallback.adapty.io/api/v1")!,
            configsUrl: URL(string: "https://configs-cdn.adapty.io/api/v1")!,
            proxy: nil
        )
        let baseUrl: URL
        let fallbackUrl: URL
        let configsUrl: URL
        let proxy: (host: String, port: Int)?
    }
}
