//
//  LocalizedViewConfiguration.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUICore {
    public struct LocalizedViewConfiguration: Sendable, Hashable {
        public let id: String
        public let locale: String
        public let isRightToLeft: Bool
        package let templateId: String
        package let screen: Screen
        package let bottomSheets: [String: BottomSheet]
        package let templateRevision: Int64
        package let selectedProducts: [String: String]
    }
}

#if DEBUG
    package extension AdaptyUICore.LocalizedViewConfiguration {
        static func create(
            id: String = UUID().uuidString,
            locale: String = AdaptyLocale.defaultPaywallLocale.id,
            isRightToLeft: Bool = false,
            templateId: String,
            screen: AdaptyUICore.Screen,
            bottomSheets: [String: AdaptyUICore.BottomSheet] = [:],
            templateRevision: Int64 = 0,
            selectedProducts: [String: String] = [:]
        ) -> Self {
            .init(
                id: id,
                locale: locale,
                isRightToLeft: isRightToLeft,
                templateId: templateId,
                screen: screen,
                bottomSheets: bottomSheets,
                templateRevision: templateRevision,
                selectedProducts: selectedProducts
            )
        }
    }
#endif

extension AdaptyUICore.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), templateRevision: \(templateRevision), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
