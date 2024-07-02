//
//  VC.Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Stack {
        let type: AdaptyUI.StackType
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let spacing: Double
        let items: [Item]
    }
}

extension AdaptyUI.ViewConfiguration.Stack {
    enum Item {
        case space(Int)
        case element(AdaptyUI.ViewConfiguration.Element)
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    private func element(_ from: AdaptyUI.ViewConfiguration.Stack.Item) throws -> AdaptyUI.Element {
        switch from {
        case let .space(value):
            .space(value)
        case let .element(value):
            try element(value)
        }
    }

    func stack(_ from: AdaptyUI.ViewConfiguration.Stack) throws -> AdaptyUI.Stack {
        try .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            content: from.items.map(element)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Stack: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case spacing
        case content
    }

    init(from decoder: any Decoder) throws {
        let def = AdaptyUI.Stack.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            type: container.decode(AdaptyUI.StackType.self, forKey: .type),
            horizontalAlignment: container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUI.ViewConfiguration.Stack.Item].self, forKey: .content)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Stack.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case count
    }

    enum ContentType: String, Codable {
        case space
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            self = try .element(AdaptyUI.ViewConfiguration.Element(from: decoder))
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        }

    }
}

extension AdaptyUI.StackType: Decodable {}
