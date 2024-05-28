//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

    import Adapty
    import SwiftUI

    @available(iOS 15.0, *)
    extension Text {
        func withAttributes(_ attributes: AdaptyUI.RichText.TextAttributes) -> Text {
            font(Font(attributes.font.uiFont(size: attributes.size)))
                .foregroundColor(attributes.txtColor.asColor?.swiftuiColor)
                .strikethrough(attributes.strike)
                .underline(attributes.underline)
//            .background(Color.yellow) as! Text
            // TODO: background
        }

        func withAttributes(_: AdaptyUI.RichText.ParagraphAttributes) -> Text {
            self
        }
    }

    @available(iOS 15.0, *)
    struct AdaptyUITextView: View {
        var text: AdaptyUI.Text

        init(_ text: AdaptyUI.Text) {
            self.text = text
        }

        // TODO: add tagConverter

        @available(iOS 15, *)
        private var attributedString: AttributedString {
            AttributedString(text.attributedString(tagConverter: nil))
        }

        private var nsAttributedString: NSAttributedString {
            text.attributedString(tagConverter: nil)
        }

        private var plainString: String {
            text.attributedString(tagConverter: nil).string
        }

        var body: some View {
            Text(attributedString)
        }
    }

    // TODO: remove before release

    #if DEBUG
        @testable import Adapty

//        @available(iOS 15.0, *)
//        extension AdaptyUI.Color {
//            static let testWhite = AdaptyUI.Color(data: 0xFFFFFFFF)
//            static let testClear = AdaptyUI.Color(data: 0xFFFFFF00)
//            static let testRed = AdaptyUI.Color(data: 0xFF0000FF)
//            static let testGreen = AdaptyUI.Color(data: 0x00FF00FF)
//            static let testBlue = AdaptyUI.Color(data: 0x0000FFFF)
//        }

        @available(iOS 15.0, *)
        extension AdaptyUI.RichText.ParagraphAttributes {
            static var test: Self {
                .create(
                    horizontalAlign: .left
                )
            }
        }

        @available(iOS 15.0, *)
        extension AdaptyUI.RichText.TextAttributes {
            static var testTitle: Self {
                .create(
                    font: .default,
                    size: 24.0,
                    txtColor: .color(.testRed)
                )
            }

            static var testBody: Self {
                .create(
                    font: .default,
                    size: 15.0,
                    txtColor: .color(.testRed)
                )
            }
        }

        @available(iOS 15.0, *)
        extension AdaptyUI.Text {

            static var testBodyShort: Self {
                .create(text:[
                    .text("Hello world!", .testBody)
                ])
            }

            static var testBodyShortAlignRight: Self {
                .create(text:[
                    .paragraph(.create(horizontalAlign: .right)),
                    .text("Hello world!", .testBody),
                ])
            }

            static var testBodyLong: Self {
                .create(text:[
                    .text("Hello world!", .testTitle),
                    .paragraph(.test),
                    .text("Hello world!", .testBody),
                ])
            }
        }

        @available(iOS 15.0, *)
        #Preview {
//    HStack {
            AdaptyUITextView(.testBodyLong)
                .background(Color.yellow)
//        Spacer()
//
//        AdaptyUI.RichText.testBodyLong
//            .background(Color.yellow)
//    }
        }
    #endif

#endif
