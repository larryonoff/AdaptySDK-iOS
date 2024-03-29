//
//  VC.OldFooterBlock.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct OldFooterBlock {
        let orderedItems: [(key: String, value: OldViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func oldFooterBlock(_ from: AdaptyUI.ViewConfiguration.OldFooterBlock) -> AdaptyUI.OldFooterBlock {
        .init(
            orderedItems: orderedOldViewItems(from.orderedItems)
        )
    }
}

extension AdaptyUI.ViewConfiguration.OldFooterBlock: Decodable {
    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.OldViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems { _ in true }
    }
}
