//
//  AdaptyUILoaderView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUILoaderView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(DefaultProgressViewStyle())
                .tint(Color(UIColor.systemBackground))
                .scaleEffect(CGSize(width: 1.5, height: 1.5))
        }
    }
}

@available(iOS 15.0, *)
#Preview {
    AdaptyUILoaderView()
}

#endif
