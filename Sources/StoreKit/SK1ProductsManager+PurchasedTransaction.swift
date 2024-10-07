//
//  SK1ProductsManager+PurchasedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import Foundation

private let log = Log.Category(name: "SK1ProductsManager")

extension SK1ProductsManager {
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK1Transaction sk1Transaction: (value: SK1Transaction, id: String)
    ) async -> PurchasedTransaction {
        await PurchasedTransaction(
            sk1Product: try? fetchSK1Product(
                id: sk1Transaction.value.payment.productIdentifier,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            purchasedSK1Transaction: sk1Transaction
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK2Transaction sk2Transaction: SK2Transaction
    ) async -> PurchasedTransaction {
        await PurchasedTransaction(
            sk1Product: try? fetchSK1Product(
                id: sk2Transaction.productID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            purchasedSK2Transaction: sk2Transaction
        )
    }
}

private extension PurchasedTransaction {
    init(
        sk1Product: SK1Product?,
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK1Transaction sk1Transaction: (value: SK1Transaction, id: String)
    ) {
        let (sk1Transaction, transactionIdentifier) = sk1Transaction

        let offer = SubscriptionOffer(
            sk1Transaction: sk1Transaction,
            sk1Product: sk1Product
        )

        self.init(
            transactionId: sk1Transaction.unfIdentifier ?? transactionIdentifier,
            originalTransactionId: sk1Transaction.unfOriginalIdentifier ?? transactionIdentifier,
            vendorProductId: sk1Transaction.payment.productIdentifier,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk1Product?.price.decimalValue,
            priceLocale: sk1Product?.priceLocale.unfCurrencyCode,
            storeCountry: sk1Product?.priceLocale.unfRegionCode,
            subscriptionOffer: offer,
            environment: nil
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(
        sk1Product: SK1Product?,
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK2Transaction sk2Transaction: SK2Transaction
    ) {
        let offer: PurchasedTransaction.SubscriptionOffer? = {
            #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
                if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                    return .init(
                        sk2TransactionOffer: sk2Transaction.offer,
                        sk1Product: sk1Product
                    )
                }
            #endif
            return .init(
                sk2Transaction: sk2Transaction,
                sk1Product: sk1Product
            )
        }()

        self.init(
            transactionId: sk2Transaction.unfIdentifier,
            originalTransactionId: sk2Transaction.unfOriginalIdentifier,
            vendorProductId: sk2Transaction.productID,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk1Product?.price.decimalValue,
            priceLocale: sk1Product?.priceLocale.unfCurrencyCode,
            storeCountry: sk1Product?.priceLocale.unfRegionCode,
            subscriptionOffer: offer,
            environment: sk2Transaction.unfEnvironment
        )
    }
}

private extension PurchasedTransaction.SubscriptionOffer {
    init?(
        sk1Transaction: SK1Transaction,
        sk1Product: SK1Product?
    ) {
        guard let offerId = sk1Transaction.payment.paymentDiscount?.identifier else {
            let sk1ProductOffer = sk1Product?.subscriptionOffer(
                byType: .introductory
            )

            guard let sk1ProductOffer else { return nil }

            self.init(
                id: nil,
                period: sk1ProductOffer.subscriptionPeriod.asAdaptyProductSubscriptionPeriod,
                paymentMode: sk1ProductOffer.paymentMode.asPaymentMode,
                offerType: .introductory,
                price: sk1ProductOffer.price.decimalValue
            )
            return
        }

        let sk1ProductOffer = sk1Product?.subscriptionOffer(
            byType: .promotional,
            withId: offerId
        )

        if let sk1ProductOffer {
            self.init(
                id: sk1ProductOffer.identifier,
                period: sk1ProductOffer.subscriptionPeriod.asAdaptyProductSubscriptionPeriod,
                paymentMode: sk1ProductOffer.paymentMode.asPaymentMode,
                offerType: .promotional,
                price: sk1ProductOffer.price.decimalValue
            )
        } else {
            self.init(id: offerId, offerType: .promotional)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension PurchasedTransaction.SubscriptionOffer {
    init?(
        sk2Transaction: SK2Transaction,
        sk1Product: SK1Product?
    ) {
        guard let offerType = sk2Transaction.unfOfferType?.asPurchasedTransactionOfferType else { return nil }

        let sk1ProductOffer = sk1Product?.subscriptionOffer(
            byType: offerType,
            withId: sk2Transaction.unfOfferId
        )

        self.init(
            id: sk2Transaction.unfOfferId,
            period: sk1ProductOffer?.subscriptionPeriod.asAdaptyProductSubscriptionPeriod,
            paymentMode: sk1ProductOffer?.paymentMode.asPaymentMode ?? .unknown,
            offerType: offerType,
            price: sk1ProductOffer?.price.decimalValue
        )
    }

    #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
        @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
        init?(
            sk2TransactionOffer: SK2Transaction.Offer?,
            sk1Product: SK1Product?
        ) {
            guard let sk2TransactionOffer else { return nil }

            let offerType = sk2TransactionOffer.type.asPurchasedTransactionOfferType

            let sk1ProductOffer = sk1Product?.subscriptionOffer(
                byType: offerType,
                withId: sk2TransactionOffer.id
            )

            self = .init(
                id: sk2TransactionOffer.id,
                period: sk1ProductOffer?.subscriptionPeriod.asAdaptyProductSubscriptionPeriod,
                paymentMode: sk2TransactionOffer.paymentMode?.asPaymentMode ?? .unknown,
                offerType: offerType,
                price: sk1ProductOffer?.price.decimalValue
            )
        }
    #endif
}

private extension SK1Product {
    func subscriptionOffer(
        byType offerType: PurchasedTransaction.OfferType,
        withId offerId: String? = nil
    ) -> SK1Product.SubscriptionOffer? {
        switch offerType {
        case .introductory:
            return introductoryPrice
        case .promotional:
            if let offerId {
                return discounts.first(where: { $0.identifier == offerId })
            }
        default:
            return nil
        }
        return nil
    }
}
