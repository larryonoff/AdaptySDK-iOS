//
//  VC.Action.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    enum Action: Sendable {
        case openUrl(String)
        case action(AdaptyUICore.ActionAction)
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func action(_ from: AdaptyUICore.ViewConfiguration.Action) throws -> AdaptyUICore.ActionAction {
        switch from {
        case let .openUrl(stringId):
            .openUrl(urlIfPresent(stringId))
        case let .action(action):
            action
        }
    }
}

extension AdaptyUICore.ViewConfiguration.Action: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .openUrl(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .action(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

extension AdaptyUICore.ViewConfiguration.Action: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case customId = "custom_id"
        case productId = "product_id"
        case groupId = "group_id"
        case sectionId = "section_id"
        case screenId = "screen_id"
        case index
    }

    enum Types: String {
        case openUrl = "open_url"
        case openScreen = "open_screen"
        case closeScreen = "close_screen"
        case switchSection = "switch"
        case restore
        case custom
        case close
        case selectProductId = "select_product"
        case purchaseProductId = "purchase_product"
        case purchaseSelectedProduct = "purchase_selected_product"
        case unselectProduct = "unselect_product"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try Types(rawValue: container.decode(String.self, forKey: .type)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .openUrl:
            self = try .openUrl(container.decode(String.self, forKey: .url))
        case .restore:
            self = .action(.restore)
        case .close:
            self = .action(.close)
        case .custom:
            self = try .action(.custom(id: container.decode(String.self, forKey: .customId)))
        case .purchaseSelectedProduct:
            self = try .action(.purchaseSelectedProduct(
                groupId: container.decodeIfPresent(String.self, forKey: .groupId) ?? AdaptyUICore.ViewConfiguration.StringId.Product.defaultProductGroupId
            ))
        case .unselectProduct:
            self = try .action(.unselectProduct(
                groupId: container.decodeIfPresent(String.self, forKey: .groupId) ?? AdaptyUICore.ViewConfiguration.StringId.Product.defaultProductGroupId
            ))
        case .selectProductId:
            self = try .action(.selectProduct(
                id: container.decode(String.self, forKey: .productId),
                groupId: container.decodeIfPresent(String.self, forKey: .groupId) ?? AdaptyUICore.ViewConfiguration.StringId.Product.defaultProductGroupId
            ))
        case .purchaseProductId:
            self = try .action(.purchaseProduct(id: container.decode(String.self, forKey: .productId)))
        case .switchSection:
            self = try .action(.switchSection(id: container.decode(String.self, forKey: .sectionId), index: container.decode(Int.self, forKey: .index)))
        case .openScreen:
            self = try .action(.openScreen(id: container.decode(String.self, forKey: .screenId)))
        case .closeScreen:
            self = .action(.closeScreen)
        }
    }
}
