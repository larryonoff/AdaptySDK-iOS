//
//  AdaptyUIError+Description.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUIError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .adaptyNotActivated: return "You should activate Adapty SDK before using AdaptyUI"
        case .adaptyUINotActivated: return "You should activate AdaptyUI SDK before using methods"
        case .activateOnce: return "You should activate AdaptyUI SDK only once"
        case let .unsupportedTemplate(description): return description
        case let .styleNotFound(description): return description
        case let .wrongComponentType(description): return description
        case let .componentNotFound(description): return description
        case let .encoding(error), let .rendering(error): return error.localizedDescription
        }
    }
}
