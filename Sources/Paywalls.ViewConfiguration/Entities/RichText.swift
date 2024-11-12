//
//  RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUICore {
    package struct RichText: Sendable, Hashable {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item: Sendable {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(AdaptyUICore.Mode<AdaptyUICore.ImageData>?, TextAttributes)
        }

        package struct TextAttributes: Sendable, Hashable {
            package let font: AdaptyUICore.Font
            package let size: Double
            package let txtColor: Mode<Filling>
            package let imgTintColor: Mode<Filling>?
            package let background: Mode<Filling>?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

extension AdaptyUICore.RichText.Item: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attr):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attr)
        case let .tag(value, attr):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attr)
        case let .image(value, attr):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(attr)
        }
    }
}

#if DEBUG
    package extension AdaptyUICore.RichText {
        static func create(
            items: [AdaptyUICore.RichText.Item],
            fallback: [AdaptyUICore.RichText.Item]? = nil
        ) -> Self {
            .init(
                items: items,
                fallback: fallback
            )
        }
    }

    package extension AdaptyUICore.RichText.TextAttributes {
        static func create(
            font: AdaptyUICore.Font,
            size: Double? = nil,
            txtColor: AdaptyUICore.Mode<AdaptyUICore.Filling>? = nil,
            imgTintColor: AdaptyUICore.Mode<AdaptyUICore.Filling>? = nil,
            background: AdaptyUICore.Mode<AdaptyUICore.Filling>? = nil,
            strike: Bool = false,
            underline: Bool = false
        ) -> Self {
            .init(
                font: font,
                size: size ?? font.defaultSize,
                txtColor: txtColor ?? .same(font.defaultColor),
                imgTintColor: imgTintColor,
                background: background,
                strike: strike,
                underline: underline
            )
        }
    }
#endif
