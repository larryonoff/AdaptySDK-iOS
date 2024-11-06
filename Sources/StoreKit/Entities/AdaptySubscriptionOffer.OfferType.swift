//
//  AdaptySubscriptionOffer.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation

extension AdaptySubscriptionOffer {
    enum OfferTypeWithIdentifier: Sendable, Hashable {
        case introductory
        case promotional(String)
        case winBack(String)

        var identifier: String? {
            switch self {
            case .introductory:
                nil
            case let .promotional(value),
                 let .winBack(value):
                value
            }
        }

        var asOfferType: OfferType {
            switch self {
            case .introductory:
                .introductory
            case .promotional:
                .promotional
            case .winBack:
                .winBack
            }
        }
    }

    public enum OfferType: String, Sendable {
        case introductory
        case promotional
        case winBack
    }
}

extension AdaptySubscriptionOffer.OfferType: Encodable {
    public func encode(to encoder: Encoder) throws {
        let value: PurchasedTransaction.OfferType =
            switch self {
            case .introductory: .introductory
            case .promotional: .promotional
            case .winBack: .winBack
            }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
