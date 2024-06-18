//
//  AdaptyUIColumnView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIColumnView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private var column: AdaptyUI.Column

    init(_ column: AdaptyUI.Column) {
        self.column = column
    }

    private func calculateTotalWeight(
        for items: [AdaptyUI.GridItem],
        in _: GeometryProxy
    ) -> (Int, CGFloat) {
        var totalWeight = 0
        var reservedLength: CGFloat = 0.0

        for item in items {
            switch item.length {
            case let .fixed(value):
                reservedLength += value.points(screenSize: screenSize.height)
            case let .weight(value):
                totalWeight += value
            }
        }

        if column.spacing > 0 {
            reservedLength += CGFloat(column.spacing * Double(items.count - 1))
        }

        return (totalWeight, reservedLength)
    }

    @State private var contentsSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let (totalWeight, reservedLength) = calculateTotalWeight(for: column.items, in: proxy)
            let weightsAvailableLength = proxy.size.height - reservedLength

            LazyHGrid(
                rows: column.items.map { item in
                    let size: GridItem.Size
                    
                    switch item.length {
                    case let .fixed(length):
                        size = .fixed(length.points(screenSize: screenSize.width))
                    case let .weight(weight):
                        size = .fixed((Double(weight) / Double(totalWeight)) * weightsAvailableLength)
                    }

                    return GridItem(
                        size,
                        spacing: column.spacing,
                        alignment: Alignment.from(
                            horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                            vertical: item.verticalAlignment.swiftuiValue
                        )
                    )
                },
                spacing: 0.0,
                content: {
                    ForEach(0 ..< column.items.count, id: \.self) { idx in
                        AdaptyUIElementView(column.items[idx].content)
                    }
                }
            )
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(width: contentsSize.width)
    }
}

#endif
