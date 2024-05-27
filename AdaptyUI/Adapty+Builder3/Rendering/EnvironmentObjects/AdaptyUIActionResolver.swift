//
//  AdaptyUIActionResolver.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
package class AdaptyUIActionResolver: ObservableObject {
    let logId: String

    package init(logId: String) {
        self.logId = logId
    }

    func actionOccured(_ action: AdaptyUI.ButtonAction) {
        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# actionOccured \(action)")
        
        onActionOccured?(action)
    }
    
    // TODO: remove
    var onActionOccured: ((AdaptyUI.ButtonAction) -> Void)?
}

#endif
