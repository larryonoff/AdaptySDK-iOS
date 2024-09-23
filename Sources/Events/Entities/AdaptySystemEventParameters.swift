//
//  AdaptySystemEventParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.03.2023
//

import Foundation

package protocol AdaptySystemEventParameters: Sendable, Encodable {}

private enum CodingKeys: String, CodingKey {
    case name = "event_name"
    case stamp = "sdk_flow_id"
    case requestData = "request_data"
    case responseData = "response_data"
    case eventData = "event_data"

    case backendRequestId = "api_request_id"
    case success
    case error
    case metrics
}

typealias EventParameters = [String: (any Sendable & Encodable)?]

private extension Encoder {
    func encode(_ params: EventParameters?) throws {
        guard let params else { return }
        var container = container(keyedBy: AnyCodingKeys.self)
        try params.forEach {
            guard let value = $1 else { return }
            try container.encode(value, forKey: AnyCodingKeys(stringValue: $0))
        }
    }
}

enum APIRequestName: String {
    case fetchProductStates = "get_products"
    case createProfile = "create_profile"
    case fetchProfile = "get_profile"
    case updateProfile = "update_profile"
    case fetchPaywallVariations = "get_paywall_variations"
    case fetchFallbackPaywallVariations = "get_fallback_paywall_variations"
    case fetchUntargetedPaywallVariations = "get_untargeted_paywall_variations"
    case fetchViewConfiguration = "get_paywall_builder"
    case fetchFallbackViewConfiguration = "get_fallback_paywall_builder"

    case validateTransaction = "validate_transaction"
    case validateReceipt = "validate_receipt"

    case sendASAToken = "set_asa_token"
    case sendAttribution = "set_attribution"
    case setTransactionVariationId = "set_variation_id"
    case signSubscriptionOffer = "sign_offer"

    case fetchEventsBlacklist = "get_events_blacklist"
}

struct AdaptyBackendAPIRequestParameters: AdaptySystemEventParameters {
    let name: APIRequestName
    let stamp: String
    let params: EventParameters?

    init(requestName: APIRequestName, requestStamp: String, params: EventParameters? = nil) {
        self.name = requestName
        self.stamp = requestStamp
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_request_\(name.rawValue)", forKey: .name)
        try container.encode(stamp, forKey: .stamp)
        try encoder.encode(params)
    }
}

struct AdaptyBackendAPIResponseParameters: AdaptySystemEventParameters {
    let name: APIRequestName
    let stamp: String
    let backendRequestId: String?
    let metrics: HTTPMetrics?
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_response_\(name)", forKey: .name)
        try container.encode(stamp, forKey: .stamp)
        try container.encodeIfPresent(backendRequestId, forKey: .backendRequestId)
        try container.encodeIfPresent(metrics, forKey: .metrics)

        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
    }

    init(requestName: APIRequestName, requestStamp: String, _ error: Error) {
        let httpError = error as? HTTPError
        self.name = requestName
        self.stamp = requestStamp
        self.backendRequestId = httpError?.headers?.getBackendRequestId()
        self.metrics = httpError?.metrics
        self.error = httpError?.description ?? error.localizedDescription
    }

    init(requestName: APIRequestName, requestStamp: String, _ response: HTTPResponse<some Sendable>) {
        self.name = requestName
        self.stamp = requestStamp
        self.backendRequestId = response.headers.getBackendRequestId()
        self.metrics = response.metrics
        self.error = nil
    }
}

enum MethodName: String {
    case activate
    case identify
    case logout
    
    case getProfile = "get_profile"
    case updateProfile = "update_profile"
    case updateAttribution = "update_attribution"
    
    case setVariationId = "set_variation_id"
    case setVariationIdSK1 = "set_variation_id_sk1"
    case setVariationIdSK2 = "set_variation_id_sk2"
    case getPaywallProducts = "get_paywall_products"
    case getProductsIntroductoryOfferEligibility = "get_products_introductory_offer_eligibility"
    case getProductsIntroductoryOfferEligibilityByStrings = "get_products_introductory_offer_eligibility_by_strings"
    case getReceipt = "get_reciept"
    case makePurchase = "make_purchase"
    case restorePurchases  = "restore_purchases"
    
    case getPaywall = "get_paywall"
    case getPaywallForDefaultAudience = "get_untargeted_paywall"
    case setFallbackPaywalls = "set_fallback_paywalls"
    
    case logShowOnboarding = "log_show_onboarding"
    case logShowPaywall = "log_show_paywall"
    
    case presentCodeRedemptionSheet  = "present_code_redemption_sheet"
}

struct AdaptySDKMethodRequestParameters: AdaptySystemEventParameters {
    let name: MethodName
    let stamp: String
    let params: EventParameters?

    init(methodName: MethodName, stamp: String, params: EventParameters? = nil) {
        self.name = methodName
        self.stamp = stamp
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_request_\(name)", forKey: .name)
        try container.encode(stamp, forKey: .stamp)
        try encoder.encode(params)
    }
}

struct AdaptySDKMethodResponseParameters: AdaptySystemEventParameters {
    let name: MethodName
    let stamp: String?
    let params: EventParameters?
    let error: String?

    init(methodName: MethodName, stamp: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.name = methodName
        self.stamp = stamp
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_response_\(name)", forKey: .name)
        try container.encodeIfPresent(stamp, forKey: .stamp)
        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
        try encoder.encode(params)
    }
}

enum AppleMethodName: String {
    case fetchASAToken = "fetch_ASA_Token"
}
struct AdaptyAppleRequestParameters: AdaptySystemEventParameters {
    let name: AppleMethodName
    let stamp: String?
    let params: EventParameters?

    init(methodName: AppleMethodName, stamp: String? = nil, params: EventParameters? = nil) {
        self.name = methodName
        self.stamp = stamp
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_request_\(name)", forKey: .name)
        try container.encodeIfPresent(stamp, forKey: .stamp)
        try encoder.encode(params)
    }
}

struct AdaptyAppleResponseParameters: AdaptySystemEventParameters {
    let name: AppleMethodName
    let stamp: String?
    let params: EventParameters?
    let error: String?

    init(methodName: AppleMethodName, stamp: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.name = methodName
        self.stamp = stamp
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_response_\(name)", forKey: .name)
        try container.encodeIfPresent(stamp, forKey: .stamp)
        try encoder.encode(params)
        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
    }
}

struct AdaptyAppleEventQueueHandlerParameters: AdaptySystemEventParameters {
    let eventName: String
    let stamp: String?
    let params: EventParameters?
    let error: String?

    init(eventName: String, stamp: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.eventName = eventName
        self.stamp = stamp
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_event_\(eventName)", forKey: .name)
        try container.encodeIfPresent(stamp, forKey: .stamp)
        try encoder.encode(params)
        if let error {
            try container.encode(error, forKey: .error)
        }
    }
}

struct AdaptyInternalEventParameters: AdaptySystemEventParameters {
    let eventName: String
    let params: EventParameters?
    let error: String?

    init(eventName: String, params: EventParameters? = nil, error: String? = nil) {
        self.eventName = eventName
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("internal_\(eventName)", forKey: .name)
        try encoder.encode(params)
        if let error {
            try container.encode(error, forKey: .error)
        }
    }
}
