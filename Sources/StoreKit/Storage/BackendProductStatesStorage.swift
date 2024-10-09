//
//  BackendProductStatesStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol BackendProductStatesStorage: AnyObject, Sendable {
    func setBackendProductStates(_: VH<[BackendProductState]>)
    func getBackendProductStates() -> VH<[BackendProductState]>?
}