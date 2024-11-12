//
//  VideoPlayer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyUICore {
    package struct VideoPlayer: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<VideoData>

        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
    package extension AdaptyUICore.VideoPlayer {
        static func create(
            asset: AdaptyUICore.Mode<AdaptyUICore.VideoData>,
            aspect: AdaptyUICore.AspectRatio = defaultAspectRatio,
            loop: Bool = true
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                loop: loop
            )
        }
    }
#endif
