//
//  Request.LogLevel.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetLogLevel: AdaptyPluginRequest {
        static let method = Method.getLogLevel
        
        init(from jsonDictionary: AdaptyJsonDictionary) throws {}
        
        init() {}

        func execute() async throws -> AdaptyJsonData {
            .success(Adapty.logLevel)
        }
    }
    
    struct SetLogLevel: AdaptyPluginRequest {
        static let method = Method.setLogLevel
        let value: AdaptyLog.Level
        
        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                jsonDictionary.value(String.self, forKey: CodingKeys.value)
            )
        }
        
        init(_ value: String) {
            self.value = AdaptyLog.Level(stringLiteral: value)
        }
        
        func execute() async throws -> AdaptyJsonData {
            Adapty.logLevel = value
            return .success()
        }
    }
}

public extension AdaptyPlugin {
    @objc static func getLogLevel(_ completion: @escaping AdaptyJsonDataCompletion) {
        execute(with: completion) { Request.GetLogLevel() }
    }
    
    @objc static func setLogLevel(value: String, _ completion: @escaping AdaptyJsonDataCompletion) {
        execute(with: completion) { Request.SetLogLevel(value) }
    }
}