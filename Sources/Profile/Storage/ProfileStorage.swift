//
//  ProfileStorage.swift
//  AdaptySDK
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProfileIdentifierStorage: AnyObject, Sendable {
    var profileId: String { get }
}

protocol ProfileStorage: ProfileIdentifierStorage {
    func getProfile() -> VH<AdaptyProfile>?
    func setProfile(_: VH<AdaptyProfile>)

    var externalAnalyticsDisabled: Bool { get }
    var syncedTransactions: Bool { get }

    func setSyncedTransactions(_: Bool)
    func setExternalAnalyticsDisabled(_: Bool)

    var appleSearchAdsSyncDate: Date? { get }
    func setAppleSearchAdsSyncDate()

    @AdaptyActor
    func clearProfile(newProfileId: String?) 
}

extension ProfileStorage {
    func getProfile(profileId: String, withCustomerUserId customerUserId: String?) -> VH<AdaptyProfile>? {
        guard let profile = getProfile(),
              profile.value.profileId == profileId
        else { return nil }

        guard let customerUserId else { return profile }
        guard customerUserId == profile.value.customerUserId else { return nil }
        return profile
    }
}
