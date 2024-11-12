//
//  AdaptyUITimerView.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUICore {
    enum TimerTag {
        case TIMER_h
        case TIMER_hh
        case TIMER_m
        case TIMER_mm
        case TIMER_s
        case TIMER_ss
        case TIMER_S
        case TIMER_SS
        case TIMER_SSS

        case TIMER_Total_Days(Int)
        case TIMER_Total_Hours(Int)
        case TIMER_Total_Minutes(Int)
        case TIMER_Total_Seconds(Int)
        case TIMER_Total_Milliseconds(Int)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUICore.TimerTag {
    static func createFromString(_ value: String) -> AdaptyUICore.TimerTag? {
        switch value {
        case "TIMER_h": return .TIMER_h
        case "TIMER_hh": return .TIMER_hh
        case "TIMER_m": return .TIMER_m
        case "TIMER_mm": return .TIMER_mm
        case "TIMER_s": return .TIMER_s
        case "TIMER_ss": return .TIMER_ss
        case "TIMER_S": return .TIMER_S
        case "TIMER_SS": return .TIMER_SS
        case "TIMER_SSS": return .TIMER_SSS
        default: break
        }

        if value.starts(with: "TIMER_Total_Days_") {
            let nString = value.replacingOccurrences(of: "TIMER_Total_Days_", with: "")
            return .TIMER_Total_Days(Int(nString) ?? 0)
        }

        if value.starts(with: "TIMER_Total_Hours_") {
            let nString = value.replacingOccurrences(of: "TIMER_Total_Hours_", with: "")
            return .TIMER_Total_Hours(Int(nString) ?? 0)
        }

        if value.starts(with: "TIMER_Total_Minutes_") {
            let nString = value.replacingOccurrences(of: "TIMER_Total_Minutes_", with: "")
            return .TIMER_Total_Minutes(Int(nString) ?? 0)
        }

        if value.starts(with: "TIMER_Total_Seconds_") {
            let nString = value.replacingOccurrences(of: "TIMER_Total_Seconds_", with: "")
            return .TIMER_Total_Seconds(Int(nString) ?? 0)
        }

        if value.starts(with: "TIMER_Total_Milliseconds_") {
            let nString = value.replacingOccurrences(of: "TIMER_Total_Milliseconds_", with: "")
            return .TIMER_Total_Milliseconds(Int(nString) ?? 0)
        }

        return nil
    }

    func string(for timeinterval: TimeInterval) -> String? {
        switch self {
        case .TIMER_h:
            String(format: "%.1d", Int(timeinterval.truncatingRemainder(dividingBy: 86400.0) / 3600.0))
        case .TIMER_hh:
            String(format: "%.2d", Int(timeinterval.truncatingRemainder(dividingBy: 86400.0) / 3600.0))
        case .TIMER_m:
            String(format: "%.1d", Int(timeinterval.truncatingRemainder(dividingBy: 3600.0) / 60.0))
        case .TIMER_mm:
            String(format: "%.2d", Int(timeinterval.truncatingRemainder(dividingBy: 3600.0) / 60.0))
        case .TIMER_s:
            String(format: "%.1d", Int(timeinterval.truncatingRemainder(dividingBy: 60.0)))
        case .TIMER_ss:
            String(format: "%.2d", Int(timeinterval.truncatingRemainder(dividingBy: 60.0)))
        case .TIMER_S:
            String(format: "%.1d", Int(timeinterval * 10.0) % 10)
        case .TIMER_SS:
            String(format: "%.2d", Int(timeinterval * 100.0) % 100)
        case .TIMER_SSS:
            String(format: "%.3d", Int(timeinterval * 1000.0) % 1000)
        case let .TIMER_Total_Days(n):
            String(format: "%.\(n)d", Int(timeinterval / 86400.0))
        case let .TIMER_Total_Hours(n):
            String(format: "%.\(n)d", Int(timeinterval / 3600.0))
        case let .TIMER_Total_Minutes(n):
            String(format: "%.\(n)d", Int(timeinterval / 60.0))
        case let .TIMER_Total_Seconds(n):
            String(format: "%.\(n)d", Int(timeinterval))
        case let .TIMER_Total_Milliseconds(n):
            String(format: "%.\(n)d", Int(timeinterval * 1000.0))
        }
    }

    var updatesPerSecond: Int {
        switch self {
        case .TIMER_S: 10
        case let .TIMER_Total_Milliseconds(n) where n == 1: 10
        case .TIMER_SS: 100
        case let .TIMER_Total_Milliseconds(n) where n == 2: 100
        case .TIMER_SSS: 120
        case let .TIMER_Total_Milliseconds(n) where n >= 3: 120
        default: 1
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUICore.RichText {
    var timerUpdatesPerSecond: Int {
        var result = 1

        for item in items {
            if case let .tag(tagValue, _) = item,
               let timerTag = AdaptyUICore.TimerTag.createFromString(tagValue)
            {
                result = max(timerTag.updatesPerSecond, result)
            }
        }

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUITimerView: View, AdaptyTagResolver {
    @Environment(\.adaptyScreenId)
    private var screenId: String

    @EnvironmentObject var viewModel: AdaptyTimerViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyTagResolverViewModel

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    private var timer: AdaptyUICore.Timer

    init(_ timer: AdaptyUICore.Timer) {
        self.timer = timer
    }

    let startTime: Date = .init()

    @State var timeLeft: TimeInterval = 0.0
    @State var text: AdaptyUICore.RichText?

    func replacement(for tag: String) -> String? {
        guard let timerTag = AdaptyUICore.TimerTag.createFromString(tag) else {
            return customTagResolverViewModel.replacement(for: tag)
        }

        return timerTag.string(for: timeLeft)
    }

    @ViewBuilder
    private var timerOrEmpty: some View {
        if let text {
            text
                .convertToSwiftUIText(
                    tagResolver: self,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(timer.horizontalAlign)
                .lineLimit(1)
                .minimumScaleFactor(0.01)
        } else {
            Text("")
        }
    }

    var body: some View {
        timerOrEmpty
            .onAppear {
                updateTime()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }

    @State private var timeCounter: Timer?
    @State private var currentTimerUpdatesPerSecond = 1 {
        didSet {
            startTimer()
        }
    }

    private func startTimer() {
        stopTimer()

        timeCounter = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            Task { @MainActor in
                updateTime()
            }
        }
    }

    private func stopTimer() {
        timeCounter?.invalidate()
        timeCounter = nil
    }

    private func updateTime() {
        var timeLeft = viewModel.timeLeft(for: timer,
                                          at: Date(),
                                          screenId: screenId)

        guard timeLeft > 0 else {
            timeLeft = 0

            stopTimer()

            text = timer.format(byValue: timeLeft)
            self.timeLeft = timeLeft
            return
        }

        text = timer.format(byValue: timeLeft)
        currentTimerUpdatesPerSecond = text?.timerUpdatesPerSecond ?? 1

        self.timeLeft = timeLeft
    }
}

#endif
