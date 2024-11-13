//
//  Pager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.05.2024
//
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Pager: Sendable, Hashable {
        static let `default` = Pager(
            pageWidth: .default,
            pageHeight: .default,
            pagePadding: .zero,
            spacing: 0,
            content: [],
            pageControl: nil,
            animation: nil,
            interactionBehaviour: .default
        )

        package let pageWidth: Length
        package let pageHeight: Length
        package let pagePadding: EdgeInsets
        package let spacing: Double
        package let content: [Element]
        package let pageControl: PageControl?
        package let animation: Animation?
        package let interactionBehaviour: InteractionBehaviour
    }
}

extension AdaptyViewConfiguration.Pager {
    package enum Length: Sendable {
        static let `default` = Length.parent(1)
        case fixed(AdaptyViewConfiguration.Unit)
        case parent(Double)
    }

    package enum InteractionBehaviour: String {
        static let `default` = InteractionBehaviour.pauseAnimation
        case none
        case cancelAnimation
        case pauseAnimation
    }

    package struct PageControl: Sendable, Hashable {
        static let `default`: Self = .init(
            layout: .stacked,
            verticalAlignment: .bottom,
            padding: .init(same: .point(6)),
            dotSize: 6,
            spacing: 6,
            color: .same(AdaptyViewConfiguration.Color.white),
            selectedColor: .same(AdaptyViewConfiguration.Color.lightGray)
        )

        package enum Layout: String {
            case overlaid
            case stacked
        }

        package let layout: Layout
        package let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        package let padding: AdaptyViewConfiguration.EdgeInsets
        package let dotSize: Double
        package let spacing: Double
        package let color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>
        package let selectedColor: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>
    }

    package struct Animation: Sendable, Hashable {
        static let defaultStartDelay: TimeInterval = 0.0
        static let defaultAfterInteractionDelay: TimeInterval = 3.0

        package let startDelay: TimeInterval
        package let pageTransition: AdaptyViewConfiguration.TransitionSlide
        package let repeatTransition: AdaptyViewConfiguration.TransitionSlide?
        package let afterInteractionDelay: TimeInterval
    }
}

extension AdaptyViewConfiguration.Pager.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .parent(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Pager {
        static func create(
            pageWidth: Length = `default`.pageWidth,
            pageHeight: Length = `default`.pageHeight,
            pagePadding: AdaptyViewConfiguration.EdgeInsets = `default`.pagePadding,
            spacing: Double = `default`.spacing,
            content: [AdaptyViewConfiguration.Element] = `default`.content,
            pageControl: PageControl? = `default`.pageControl,
            animation: Animation? = `default`.animation,
            interactionBehaviour: InteractionBehaviour = `default`.interactionBehaviour
        ) -> Self {
            .init(
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                pagePadding: pagePadding,
                spacing: spacing,
                content: content,
                pageControl: pageControl,
                animation: animation,
                interactionBehaviour: interactionBehaviour
            )
        }
    }

    package extension AdaptyViewConfiguration.Pager.PageControl {
        static func create(
            layout: Layout = `default`.layout,
            verticalAlignment: AdaptyViewConfiguration.VerticalAlignment = `default`.verticalAlignment,
            padding: AdaptyViewConfiguration.EdgeInsets = `default`.padding,
            dotSize: Double = `default`.dotSize,
            spacing: Double = `default`.spacing,
            color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color> = `default`.color,
            selectedColor: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color> = `default`.selectedColor
        ) -> Self {
            .init(
                layout: layout,
                verticalAlignment: verticalAlignment,
                padding: padding,
                dotSize: dotSize,
                spacing: spacing,
                color: color,
                selectedColor: selectedColor
            )
        }
    }

    package extension AdaptyViewConfiguration.Pager.Animation {
        static func create(
            startDelay: TimeInterval = defaultStartDelay,
            pageTransition: AdaptyViewConfiguration.TransitionSlide = .create(),
            repeatTransition: AdaptyViewConfiguration.TransitionSlide? = nil,
            afterInteractionDelay: TimeInterval = defaultAfterInteractionDelay
        ) -> Self {
            .init(
                startDelay: startDelay,
                pageTransition: pageTransition,
                repeatTransition: repeatTransition,
                afterInteractionDelay: afterInteractionDelay
            )
        }
    }
#endif

extension AdaptyViewConfiguration.Pager.InteractionBehaviour: Decodable {
    package init(from decoder: Decoder) throws {
        self =
            switch try decoder.singleValueContainer().decode(String.self) {
            case "none": .none
            case "cancel_animation": .cancelAnimation
            case "pause_animation": .pauseAnimation
            default: .default
            }
    }
}

extension AdaptyViewConfiguration.Pager.PageControl.Layout: Decodable {}

extension AdaptyViewConfiguration.Pager.Animation: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case pageTransition = "page_transition"
        case repeatTransition = "repeat_transition"
        case afterInteractionDelay = "after_interaction_delay"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyViewConfiguration.Pager.Animation.defaultStartDelay
        pageTransition = try container.decodeIfPresent(AdaptyViewConfiguration.TransitionSlide.self, forKey: .pageTransition) ?? AdaptyViewConfiguration.TransitionSlide.default
        repeatTransition = try container.decodeIfPresent(AdaptyViewConfiguration.TransitionSlide.self, forKey: .repeatTransition)
        afterInteractionDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyViewConfiguration.Pager.Animation.defaultAfterInteractionDelay
    }
}