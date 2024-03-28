//
//  HorizontalAlignment.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public enum HorizontalAlignment: String {
        case left
        case center
        case right
        case fill
    }
}

extension AdaptyUI.HorizontalAlignment: Decodable {}