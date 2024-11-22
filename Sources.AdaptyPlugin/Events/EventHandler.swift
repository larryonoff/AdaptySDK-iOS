//
//  Event.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI

public protocol EventHandler: Sendable {
    func handle(event: AdaptyPluginEvent)
}

enum Event {}

public extension AdaptyPlugin {
    @MainActor
    private static var delegate: AdaptyPluginDelegate?

    @MainActor
    static func reqister(eventHandler: EventHandler) {
        let delegate = AdaptyPluginDelegate(eventHandler: eventHandler)
        self.delegate = delegate
        Adapty.delegate = delegate
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            AdaptyUI.universalDelagate = delegate
        }
    }
}
