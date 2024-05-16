//
//  AdaptyUIScreenSizeEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 13.0, *)
struct AdaptyUIScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .init(width: 320, height: 480)
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var adaptyScreenSize: CGSize {
        get { self[AdaptyUIScreenSizeKey.self] }
        set { self[AdaptyUIScreenSizeKey.self] = newValue }
    }
}

@available(iOS 13.0, *)
extension View {
    func withScreenSize(_ value: CGSize) -> some View {
        environment(\.adaptyScreenSize, value)
    }
}

#endif
