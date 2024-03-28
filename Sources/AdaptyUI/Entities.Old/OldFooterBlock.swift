//
//  OldFooterBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    public struct OldFooterBlock {
        public let items: [String: AdaptyUI.LocalizedViewItem]
        public let orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]
        init(orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            items = [String: AdaptyUI.LocalizedViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }
}