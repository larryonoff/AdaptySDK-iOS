//
//  VC.Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Text {
        let fontAssetId: String?
        let size: Double?
        let fillAssetId: String?
        let items: [Item]
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletSpace: Double?

        enum Item {
            case text(TextItem)
            case image(ImageItem)
            case newline
            case space(Double)
        }

        struct TextItem {
            let stringId: String
            let fontAssetId: String?
            let size: Double?
            let fillAssetId: String?
            let horizontalAlign: AdaptyUI.HorizontalAlign?
            let isBullet: Bool
        }

        struct ImageItem {
            let imageAssetId: String
            let colorAssetId: String?
            let width: Double
            let height: Double
            let isBullet: Bool
        }
    }
}

extension AdaptyUI.ViewConfiguration.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case items
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletSpace = "bullet_space"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)

        if container.contains(.items) {
            items = try container.decode([Item].self, forKey: .items)
            if items.compactMap({
                if case let .text(item) = $0 { return item }
                return nil
            }).contains(where: { $0.fontAssetId == nil }) {
                fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            } else {
                fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
            }
            if items.contains(where: {
                if case let .image(item) = $0 { return item.isBullet }
                if case let .text(item) = $0 { return item.isBullet }
                return false
            }) {
                bulletSpace = try container.decode(Double.self, forKey: .bulletSpace)
            } else {
                bulletSpace = try container.decodeIfPresent(Double.self, forKey: .bulletSpace)
            }
        } else {
            fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            bulletSpace = try container.decodeIfPresent(Double.self, forKey: .bulletSpace)
            items = [.text(TextItem(
                stringId: try container.decode(String.self, forKey: .stringId),
                fontAssetId: nil,
                size: nil,
                fillAssetId: nil,
                horizontalAlign: nil,
                isBullet: false
            ))]
        }
    }
}

extension AdaptyUI.ViewConfiguration.Text.TextItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case isBullet = "bullet"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(String.self, forKey: .stringId)
        fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)
        isBullet = try container.decodeIfPresent(Bool.self, forKey: .isBullet) ?? false
    }
}

extension AdaptyUI.ViewConfiguration.Text.ImageItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case imageAssetId = "image"
        case colorAssetId = "color"
        case width
        case height
        case isBullet = "bullet"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageAssetId = try container.decode(String.self, forKey: .imageAssetId)
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        isBullet = try container.decodeIfPresent(Bool.self, forKey: .isBullet) ?? false
    }
}

extension AdaptyUI.ViewConfiguration.Text.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case image
        case stringId = "string_id"
        case space
        case newline
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.stringId) {
            self = .text(try AdaptyUI.ViewConfiguration.Text.TextItem(from: decoder))
        } else if container.contains(.image) {
            self = .image(try AdaptyUI.ViewConfiguration.Text.ImageItem(from: decoder))
        } else if container.contains(.newline) {
            self = .newline
        } else {
            self = .space(try container.decodeIfPresent(Double.self, forKey: .space) ?? 0.0)
        }
    }
}
