//
//  RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    package struct RichText {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(AdaptyUI.ImageData, TextAttributes)
        }

        package struct TextAttributes {
            package let font: AdaptyUI.Font
            package let size: Double
            package let txtColor: AdaptyUI.Filling
            package let imgTintColor: AdaptyUI.Filling?
            package let background: AdaptyUI.Filling?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

#if DEBUG
    package extension AdaptyUI.RichText {
        static func create(
            items: [AdaptyUI.RichText.Item],
            fallback: [AdaptyUI.RichText.Item]? = nil
        ) -> Self {
            .init(
                items: items,
                fallback: fallback
            )
        }
    }

    package extension AdaptyUI.RichText.TextAttributes {
        static func create(
            font: AdaptyUI.Font,
            size: Double? = nil,
            txtColor: AdaptyUI.Filling? = nil,
            imgTintColor: AdaptyUI.Filling? = nil,
            background: AdaptyUI.Filling? = nil,
            strike: Bool = false,
            underline: Bool = false
        ) -> Self {
            .init(
                font: font,
                size: size ?? font.defaultSize,
                txtColor: txtColor ?? font.defaultColor,
                imgTintColor: imgTintColor,
                background: background,
                strike: strike,
                underline: underline
            )
        }
    }
#endif
