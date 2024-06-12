//
//  LazyLocalisedProductText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 02.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct LazyLocalisedProductText {
        package let adaptyProductId: String
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?

        init(
            adaptyProductId: String,
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?
        ) {
            self.adaptyProductId = adaptyProductId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText(
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            if let value = richTextOrNil(byPaymentMode: mode) {
                value
            } else if mode == .unknown {
                .empty
            } else {
                richTextOrNil(byPaymentMode: .unknown) ?? .empty
            }
        }

        private func richTextOrNil(
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText? {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),

                defaultTextAttributes: defaultTextAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText {
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?

        init(
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?
        ) {
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText() -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) ?? .empty
        }

        package func richText(
            adaptyProductId: String,
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            if let value = richTextOrNil(adaptyProductId: adaptyProductId, byPaymentMode: mode) {
                value
            } else if mode == .unknown {
                .empty
            } else {
                richTextOrNil(adaptyProductId: adaptyProductId, byPaymentMode: .unknown) ?? .empty
            }
        }

        private func richTextOrNil(
            adaptyProductId: String,
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText? {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }
}
