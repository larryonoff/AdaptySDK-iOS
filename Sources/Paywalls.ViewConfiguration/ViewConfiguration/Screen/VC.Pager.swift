//
//  VC.Pager.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Pager: Sendable, Hashable {
        let pageWidth: AdaptyUICore.Pager.Length
        let pageHeight: AdaptyUICore.Pager.Length
        let pagePadding: AdaptyUICore.EdgeInsets
        let spacing: Double
        let content: [AdaptyUICore.ViewConfiguration.Element]
        let pageControl: AdaptyUICore.ViewConfiguration.Pager.PageControl?
        let animation: AdaptyUICore.Pager.Animation?
        let interactionBehaviour: AdaptyUICore.Pager.InteractionBehaviour
    }
}

extension AdaptyUICore.ViewConfiguration.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: AdaptyUICore.Pager.PageControl.Layout
        let verticalAlignment: AdaptyUICore.VerticalAlignment
        let padding: AdaptyUICore.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func pager(_ from: AdaptyUICore.ViewConfiguration.Pager) throws -> AdaptyUICore.Pager {
        try .init(
            pageWidth: from.pageWidth,
            pageHeight: from.pageHeight,
            pagePadding: from.pagePadding,
            spacing: from.spacing,
            content: from.content.map(element),
            pageControl: from.pageControl.map(pageControl),
            animation: from.animation,
            interactionBehaviour: from.interactionBehaviour
        )
    }

    private func pageControl(_ from: AdaptyUICore.ViewConfiguration.Pager.PageControl) throws -> AdaptyUICore.Pager.PageControl {
        .init(
            layout: from.layout,
            verticalAlignment: from.verticalAlignment,
            padding: from.padding,
            dotSize: from.dotSize,
            spacing: from.spacing,
            color: from.colorAssetId.flatMap { try? color($0) } ?? AdaptyUICore.Pager.PageControl.default.color,
            selectedColor: from.selectedColorAssetId.flatMap { try? color($0) } ?? AdaptyUICore.Pager.PageControl.default.selectedColor
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Pager: Decodable {
    enum CodingKeys: String, CodingKey {
        case pageWidth = "page_width"
        case pageHeight = "page_height"
        case pagePadding = "page_padding"
        case spacing
        case content
        case pageControl = "page_control"
        case animation
        case interactionBehaviour = "interaction"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = AdaptyUICore.Pager.default
        pageWidth = try container.decodeIfPresent(AdaptyUICore.Pager.Length.self, forKey: .pageWidth) ?? def.pageWidth
        pageHeight = try container.decodeIfPresent(AdaptyUICore.Pager.Length.self, forKey: .pageHeight) ?? def.pageHeight
        pagePadding = try container.decodeIfPresent(AdaptyUICore.EdgeInsets.self, forKey: .pagePadding) ?? def.pagePadding
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        content = try container.decode([AdaptyUICore.ViewConfiguration.Element].self, forKey: .content)
        pageControl = try container.decodeIfPresent(AdaptyUICore.ViewConfiguration.Pager.PageControl.self, forKey: .pageControl)
        animation = try container.decodeIfPresent(AdaptyUICore.Pager.Animation.self, forKey: .animation)
        interactionBehaviour = try container.decodeIfPresent(AdaptyUICore.Pager.InteractionBehaviour.self, forKey: .interactionBehaviour) ?? def.interactionBehaviour
    }
}

extension AdaptyUICore.ViewConfiguration.Pager.PageControl: Decodable {
    enum CodingKeys: String, CodingKey {
        case layout
        case verticalAlignment = "v_align"
        case padding
        case dotSize = "dot_size"
        case spacing
        case colorAssetId = "color"
        case selectedColorAssetId = "selected_color"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = AdaptyUICore.Pager.PageControl.default
        layout = try container.decodeIfPresent(AdaptyUICore.Pager.PageControl.Layout.self, forKey: .layout) ?? def.layout
        verticalAlignment = try container.decodeIfPresent(AdaptyUICore.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment
        padding = try container.decodeIfPresent(AdaptyUICore.EdgeInsets.self, forKey: .padding) ?? def.padding
        dotSize = try container.decodeIfPresent(Double.self, forKey: .dotSize) ?? def.dotSize
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        selectedColorAssetId = try container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
    }
}

extension AdaptyUICore.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyUICore.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Double.self, forKey: .parent) {
                self = .parent(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found parent"))
            }
        }
    }
}
