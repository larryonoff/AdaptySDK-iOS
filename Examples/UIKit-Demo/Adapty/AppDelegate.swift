//
//  AppDelegate.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import Adapty
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private func instantiateTestingController() -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestingController")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.delegate = PurchasesObserver.shared
        Adapty.logLevel = .verbose
        Adapty.activate(AppConstants.adaptyApiKey) { _ in
            PurchasesObserver.shared.loadInitialProfileData()
            PurchasesObserver.shared.loadInitialPaywallData()
        }

        let configurationBuilder =
            Adapty.Configuration
                .Builder(withAPIKey: AppConstants.adaptyApiKey)
                .with(observerMode: false)
                .with(customerUserId: nil)
                .with(idfaCollectionDisabled: false)
                .with(ipAddressCollectionDisabled: false)

        Adapty.activate(with: configurationBuilder) { _ in
            PurchasesObserver.shared.loadInitialProfileData()
            PurchasesObserver.shared.loadInitialPaywallData()
        }

        // in case you have / want to use fallback paywalls
        if let urlPath = Bundle.main.url(forResource: "fallback_paywalls", withExtension: "json") {
            Adapty.setFallbackPaywalls(fileURL: urlPath) { _ in
                // handle error
            }
        }

        return true
    }
}
