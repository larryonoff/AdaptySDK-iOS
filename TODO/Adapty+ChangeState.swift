//
//  Adapty+ChangeState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

public final class Adapty {
    static var shared: Adapty?
    let profileStorage: ProfileStorage
    let apiKeyPrefix: String
    let backend: Backend

    let httpSession: HTTPSession
    lazy var httpFallbackSession: HTTPSession = backend.fallback.createHTTPSession(responseQueue: Adapty.underlayQueue)

    lazy var httpConfigsSession: HTTPSession = backend.configs.createHTTPSession(responseQueue: Adapty.underlayQueue)

    let skProductsManager: SKProductsManager
    let sk1ReceiptManager: SK1ReceiptManager
    let _sk2TransactionManager: Any?
    let sk1QueueManager: SK1QueueManager
    let vendorIdsCache: ProductVendorIdsCache
    var state: State

    init(
        apiKeyPrefix: String,
        profileStorage: ProfileStorage,
        vendorIdsStorage: ProductVendorIdsStorage,
        backend: Backend,
        customerUserId: String?
    ) {
        self.apiKeyPrefix = apiKeyPrefix
        self.backend = backend

        self.profileStorage = profileStorage
        vendorIdsCache = ProductVendorIdsCache(storage: vendorIdsStorage)
        httpSession = backend.createHTTPSession(responseQueue: Adapty.underlayQueue)
        skProductsManager = SKProductsManager(apiKeyPrefix: apiKeyPrefix, storage: UserDefaults.standard, backend: backend)

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            _sk2TransactionManager = SK2TransactionManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, backend: backend)
        } else {
            _sk2TransactionManager = nil
        }

        sk1ReceiptManager = SK1ReceiptManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, backend: backend, refreshIfEmpty: _sk2TransactionManager == nil)

        sk1QueueManager = SK1QueueManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, skProductsManager: skProductsManager)

        state = .initializingTo(customerUserId: customerUserId)
        sk1QueueManager.startObserving(purchaseValidator: self)
        startSyncIPv4OnceIfNeeded()
        initializingProfileManager(toCustomerUserId: customerUserId)
    }

    private var profileManagerCompletionHandlers: [AdaptyResultCompletion<ProfileManager>]?
    private var profileManagerOrFailedCompletionHandlers: [AdaptyResultCompletion<ProfileManager>]?

    private var logoutCompletionHandlers: [AdaptyErrorCompletion]?

    @inline(__always)
    func getProfileManager(waitCreatingProfile: Bool = true, _ completion: @escaping AdaptyResultCompletion<ProfileManager>) {
        if let result = state.initializedResult {
            completion(result)
            return
        }

        if waitCreatingProfile {
            if let handlers = profileManagerCompletionHandlers {
                profileManagerCompletionHandlers = handlers + [completion]
                return
            }
            profileManagerCompletionHandlers = [completion]
        } else {
            if let handlers = profileManagerOrFailedCompletionHandlers {
                profileManagerOrFailedCompletionHandlers = handlers + [completion]
                return
            }
            profileManagerOrFailedCompletionHandlers = [completion]
        }
    }

    @inline(__always)
    private func callProfileManagerCompletionHandlers(_ result: AdaptyResult<ProfileManager>) {
        let handlers: [AdaptyResultCompletion<ProfileManager>]
        if let error = result.error, error.isProfileCreateFailed {
            handlers = profileManagerOrFailedCompletionHandlers ?? []
            profileManagerOrFailedCompletionHandlers = nil
        } else {
            handlers = (profileManagerCompletionHandlers ?? []) + (profileManagerOrFailedCompletionHandlers ?? [])
            profileManagerCompletionHandlers = nil
            profileManagerOrFailedCompletionHandlers = nil
        }
        guard !handlers.isEmpty else { return }

        Adapty.underlayQueue.async {
            handlers.forEach { $0(result) }
        }
    }

    @inline(__always)
    private func callLogoutCompletionHandlers(_ error: AdaptyError?) {
        guard let handlers = logoutCompletionHandlers else { return }
        logoutCompletionHandlers = nil
        Adapty.underlayQueue.async {
            handlers.forEach { $0(error) }
        }
    }
}

extension Adapty {
    @inline(__always)
    func startLogout(_ completion: @escaping AdaptyErrorCompletion) {
        if let handlers = logoutCompletionHandlers {
            logoutCompletionHandlers = handlers + [completion]
            return
        } else {
            logoutCompletionHandlers = [completion]
        }

        switch state {
        case let .failed(error):
            callLogoutCompletionHandlers(error)
            return
        case let .initialized(manager):
            manager.isActive = false
            finishLogout()
        case .initializingTo,
             .needIdentifyTo,
             .needLogout:
            state = .needLogout
        }
    }

    @inline(__always)
    private func finishLogout() {
        profileStorage.clearProfile(newProfileId: nil)
        state = .initializingTo(customerUserId: nil)
        callLogoutCompletionHandlers(nil)
        callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
        Adapty.underlayQueue.async { [weak self] in
            self?.initializingProfileManager(toCustomerUserId: nil)
        }
    }

    @inline(__always)
    func identify(toCustomerUserId newCustomerUserId: String, _ completion: @escaping AdaptyErrorCompletion) {
        switch state {
        case let .failed(error):
            completion(error)
            return
        case let .initialized(manager):
            guard manager.profile.value.customerUserId != newCustomerUserId else {
                completion(nil)
                return
            }
            manager.isActive = false
            state = .initializingTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
            Adapty.underlayQueue.async { [weak self] in
                self?.initializingProfileManager(toCustomerUserId: newCustomerUserId)
            }
            return
        case let .initializingTo(customerUserId):
            if let customerUserId, customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case let .needIdentifyTo(customerUserId):
            if customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case .needLogout:
            profileStorage.clearProfile(newProfileId: nil)
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        }
    }

    @inline(__always)
    private func needBreakInitializing() -> Bool {
        switch state {
        case .initializingTo:
            return false
        case .failed, .initialized:
            return true
        case .needLogout:
            finishLogout()
            return true
        case let .needIdentifyTo(customerUserId):
            state = .initializingTo(customerUserId: customerUserId)
            Adapty.underlayQueue.async { [weak self] in
                self?.initializingProfileManager(toCustomerUserId: customerUserId)
            }
            return true
        }
    }

    private func initializingProfileManager(toCustomerUserId customerUserId: String?) {
        guard !needBreakInitializing() else { return }

       //...
    }

    enum State /* Hashable */ {
        case initializingTo(customerUserId: String?)
        case needLogout
        case needIdentifyTo(customerUserId: String)
        case failed(AdaptyError)
        case initialized(ProfileManager)

        var initializing: Bool {
            switch self {
            case .failed, .initialized:
                false
            default:
                true
            }
        }

        var initialized: ProfileManager? {
            switch self {
            case let .initialized(manager):
                manager
            default:
                nil
            }
        }

        var initializedResult: AdaptyResult<ProfileManager>? {
            switch self {
            case let .failed(error):
                .failure(error)
            case let .initialized(manager):
                .success(manager)
            default:
                nil
            }
        }

//        init(_ result: AdaptyResult<ProfileManager>) {
//            switch result {
//            case let .failure(error):
//                self = .failed(error)
//            case let .success(manager):
//                self = .initialized(manager)
//            }
//        }
    }
}