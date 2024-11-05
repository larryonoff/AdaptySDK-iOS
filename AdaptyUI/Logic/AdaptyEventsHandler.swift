//
//  AdaptyEventsHandler.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
@MainActor
package final class AdaptyEventsHandler {
    let logId: String = Log.stamp

    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?
    private let didFailPurchase: ((AdaptyPaywallProduct, AdaptyError) -> Void)?
    private let didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: ((AdaptyProfile) -> Void)?
    private let didFailRestore: ((AdaptyError) -> Void)?
    private let didFailRendering: ((AdaptyError) -> Void)?
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?
    private let didPartiallyLoadProducts: (([String]) -> Void)?

    package init() {
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didFinishPurchase = nil
        self.didFailPurchase = nil
        self.didCancelPurchase = nil
        self.didStartRestore = nil
        self.didFinishRestore = nil
        self.didFailRestore = nil
        self.didFailRendering = nil
        self.didFailLoadingProducts = nil
        self.didPartiallyLoadProducts = nil
    }

    package init(
        logId: String,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: @escaping (AdaptyPaywallProductWithoutDeterminingOffer) -> Void,
        didStartPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didStartRestore: @escaping () -> Void,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool,
        didPartiallyLoadProducts: @escaping ([String]) -> Void
    ) {
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didFailPurchase = didFailPurchase
        self.didCancelPurchase = didCancelPurchase
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRestore = didFailRestore
        self.didFailRendering = didFailRendering
        self.didFailLoadingProducts = didFailLoadingProducts
        self.didPartiallyLoadProducts = didPartiallyLoadProducts
    }

    func event_didPerformAction(_ action: AdaptyUI.Action) {
        Log.ui.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ product: AdaptyPaywallProductWithoutDeterminingOffer) {
        Log.ui.verbose("#\(logId)# event_didSelectProduct: \(product.vendorProductId)")
        didSelectProduct?(product)
    }

    func event_didStartPurchase(product: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# makePurchase begin")
        didStartPurchase?(product)
    }

    func event_didCancelPurchase(product: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# event_didCancelPurchase: \(product.vendorProductId)")
        didCancelPurchase?(product)
    }

    func event_didFinishPurchase(
        product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        Log.ui.verbose("#\(logId)# event_didFinishPurchase: \(product.vendorProductId)")
        didFinishPurchase?(product, purchaseResult)
    }

    func event_didFailPurchase(
        product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        Log.ui.verbose("#\(logId)# event_didFailPurchase: \(product.vendorProductId), \(error)")
        didFailPurchase?(product, error)
    }

    func event_didStartRestore() {
        Log.ui.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    func event_didFinishRestore(with profile: AdaptyProfile) {
        Log.ui.verbose("#\(logId)# event_didFinishRestore")
        didFinishRestore?(profile)
    }

    func event_didFailRestore(with error: AdaptyError) {
        Log.ui.error("#\(logId)# event_didFailRestore: \(error)")
        didFailRestore?(error)
    }

    func event_didFailRendering(with error: AdaptyUIError) {
        Log.ui.error("#\(logId)# event_didFailRendering: \(error)")
        didFailRendering?(AdaptyError(error))
    }

    func event_didFailLoadingProducts(with error: AdaptyError) -> Bool {
        Log.ui.error("#\(logId)# event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }

    func event_didPartiallyLoadProducts(failedProductIds: [String]) {
        Log.ui.error("#\(logId)# event_didPartiallyLoadProducts: \(failedProductIds)")
        didPartiallyLoadProducts?(failedProductIds)
    }
}

#endif
