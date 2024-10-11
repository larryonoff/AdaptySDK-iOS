//
//  EventsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

private let log = Log.events

actor EventsManager {
    private enum Constants {
        static let sendingLimitEvents = 500
    }

    private let profileStorage: ProfileIdentifierStorage
    private let eventStorages: [EventCollectionStorage]
    private var configuration: EventsBackendConfiguration
    private var backendSession: Backend.EventsExecutor?
    private var sending: Bool = false

    init(
        profileStorage: ProfileIdentifierStorage
    ) {
        self.init(
            profileStorage: profileStorage,
            eventStorages: [
                EventCollectionStorage(with: UserDefaults.standard.defaultEventsStorage),
                EventCollectionStorage(with: UserDefaults.standard.sysLogEventsStorage),
            ]
        )
    }

    private init(
        profileStorage: ProfileIdentifierStorage,
        eventStorages: [EventCollectionStorage]
    ) {
        self.profileStorage = profileStorage
        self.eventStorages = eventStorages

        let configuration = EventsBackendConfiguration()
        self.configuration = configuration
    }

    func set(backend: Backend) {
        backendSession = backend.createEventsExecutor()
        guard eventStorages.hasEvents || configuration.isExpired else { return }
        needSendEvents()
    }

    func trackEvent(_ unpacked: Event.Unpacked) throws {
        guard !configuration.blacklist.contains(unpacked.event.name.rawValue) else {
            return
        }

        do {
            if unpacked.event.isLowPriority {
                try self.eventStorages.last?.add(unpacked)
            } else {
                try self.eventStorages.first?.add(unpacked)
            }
        } catch {
            let error = EventsError.encoding(error)
            log.error(error.description)
            throw error
        }

        needSendEvents()
    }

    private func hasEvents() -> Bool {
        eventStorages.hasEvents
    }

    private func needSendEvents() {
        guard let backendSession, !sending else { return }

        sending = true

        Task(priority: .utility) { [weak self] in

            var error: Error?
            do {
                try await self?.sendEvents(backendSession)
            } catch let err {
                error = err
            }

            let interval: TaskDuration? =
                if let error, !((error as? EventsError)?.isInterrupted ?? false) {
                    .seconds(20)
                } else if await (self?.hasEvents()) ?? false {
                    .seconds(1)
                } else {
                    nil
                }

            guard let interval else {
                await self?.finishSending()
                return
            }

            Task.detached(priority: .utility) { [weak self] in
                try? await Task.sleep(duration: interval)
                await self?.finishSending()
                await self?.needSendEvents()
            }
        }
    }

    private func sendEvents(_ session: Backend.EventsExecutor) async throws {
        if configuration.isExpired {
            configuration = try await session.fetchEventsConfig(
                profileId: profileStorage.profileId
            )
        }

        let events = self.eventStorages.getEvents(
            limit: Constants.sendingLimitEvents,
            blackList: self.configuration.blacklist
        )

        guard !events.elements.isEmpty else {
            self.eventStorages.subtract(oldIndexes: events.endIndex)
            return
        }

        try await session.sendEvents(
            profileId: self.profileStorage.profileId,
            events: events.elements
        )

        self.eventStorages.subtract(oldIndexes: events.endIndex)
    }

    private func finishSending() {
        sending = false
    }
}

private extension [EventCollectionStorage] {
    var hasEvents: Bool { contains { !$0.isEmpty } }

    func getEvents(limit: Int, blackList: Set<String>) -> (elements: [Data], endIndex: [Int?]) {
        var limit = limit
        let initResult = (elements: [Data](), endIndex: [Int?]())
        return reduce(initResult) { result, storage in

            guard limit > 0,
                  let (elements, endIndex) = storage.getEvents(limit: limit, blackList: blackList)
            else {
                return (result.elements, result.endIndex + [nil])
            }

            limit -= elements.count
            return (result.elements + elements, result.endIndex + [endIndex])
        }
    }

    func subtract(oldIndexes: [Int?]) {
        zip(oldIndexes, self)
            .forEach { optionalIndex, storage in
                guard let index = optionalIndex else { return }
                storage.subtract(newStartIndex: index + 1)
            }
    }
}
