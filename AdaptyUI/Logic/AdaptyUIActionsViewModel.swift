//
//  AdaptyUIActionsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
package class AdaptyUIActionsViewModel: ObservableObject {
    let logId: String
    let eventsHandler: AdaptyEventsHandler

    package init(eventsHandler: AdaptyEventsHandler) {
        self.eventsHandler = eventsHandler
        self.logId = eventsHandler.logId
    }

    func closeActionOccurred() {
        eventsHandler.event_didPerformAction(.close)
    }
    
    func openUrlActionOccurred(url urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            Log.ui.warn("#\(logId)# can't parse url: \(urlString ?? "null")")
            return
        }
        eventsHandler.event_didPerformAction(.openURL(url: url))
    }
    
    func customActionOccurred(id: String) {
        eventsHandler.event_didPerformAction(.custom(id: id))
    }
}

#endif
