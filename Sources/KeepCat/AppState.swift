import Combine
import Foundation
import ServiceManagement

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isKeepingAwake = false
    @Published private(set) var endDate: Date?
    @Published private(set) var powerState = PowerState.unknown
    @Published private(set) var lastStopReason: StopReason?
    @Published var errorMessage: String?

    @Published var selectedMode: AwakeMode {
        didSet { defaults.set(selectedMode.rawValue, forKey: Keys.selectedMode) }
    }

    @Published var selectedDuration: SessionDuration {
        didSet { defaults.set(selectedDuration.rawValue, forKey: Keys.selectedDuration) }
    }

    @Published var stopOnLowBattery: Bool {
        didSet { defaults.set(stopOnLowBattery, forKey: Keys.stopOnLowBattery) }
    }

    @Published var lowBatteryThreshold: Int {
        didSet { defaults.set(lowBatteryThreshold, forKey: Keys.lowBatteryThreshold) }
    }

    @Published var requireACPower: Bool {
        didSet { defaults.set(requireACPower, forKey: Keys.requireACPower) }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    private let assertionController = SleepAssertionController()
    private let defaults: UserDefaults
    private var timer: Timer?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        selectedMode = AwakeMode(
            rawValue: defaults.string(forKey: Keys.selectedMode) ?? ""
        ) ?? .allowDisplaySleep

        selectedDuration = SessionDuration(
            rawValue: defaults.object(forKey: Keys.selectedDuration) as? Int ?? 3_600
        ) ?? .oneHour

        stopOnLowBattery = defaults.object(forKey: Keys.stopOnLowBattery) as? Bool ?? true
        lowBatteryThreshold = defaults.object(forKey: Keys.lowBatteryThreshold) as? Int ?? 15
        requireACPower = defaults.object(forKey: Keys.requireACPower) as? Bool ?? false
        launchAtLogin = SMAppService.mainApp.status == .enabled

        powerState = PowerMonitor.currentState()
        startMonitoring()
    }

    var statusLabel: String {
        guard isKeepingAwake else {
            return localized("status.sleeping")
        }

        guard let endDate else {
            return localized("status.awake")
        }

        return remainingTimeText(until: endDate)
    }

    var remainingTime: TimeInterval? {
        guard let endDate else { return nil }
        return max(0, endDate.timeIntervalSinceNow)
    }

    var remainingTimeDescription: String {
        guard let remainingTime else {
            return localized("duration.indefinitely")
        }
        return formatDuration(remainingTime)
    }

    func toggleSession() {
        isKeepingAwake ? stop(reason: .user) : start()
    }

    func start() {
        powerState = PowerMonitor.currentState()

        guard !requireACPower || powerState.isConnectedToAC else {
            errorMessage = localized("error.requiresPower")
            return
        }

        do {
            try assertionController.start(mode: selectedMode)
            endDate = selectedDuration.timeInterval.map { Date().addingTimeInterval($0) }
            lastStopReason = nil
            errorMessage = nil
            isKeepingAwake = true
        } catch {
            stop(reason: .systemError(error.localizedDescription))
            errorMessage = String(
                format: localized("error.couldNotStart"),
                error.localizedDescription
            )
        }
    }

    func stop(reason: StopReason) {
        assertionController.stop()
        isKeepingAwake = false
        endDate = nil
        lastStopReason = reason
    }

    func dismissError() {
        errorMessage = nil
    }

    func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .module)
    }

    func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded(.up)))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func remainingTimeText(until date: Date) -> String {
        formatDuration(date.timeIntervalSinceNow)
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        if let endDate, endDate <= Date(), isKeepingAwake {
            stop(reason: .timerFinished)
            return
        }

        guard Int(Date().timeIntervalSinceReferenceDate) % 15 == 0 else {
            objectWillChange.send()
            return
        }

        powerState = PowerMonitor.currentState()

        guard isKeepingAwake else {
            objectWillChange.send()
            return
        }

        if requireACPower && !powerState.isConnectedToAC {
            stop(reason: .disconnectedFromPower)
        } else if
            stopOnLowBattery,
            !powerState.isConnectedToAC,
            let percentage = powerState.batteryPercentage,
            percentage <= lowBatteryThreshold
        {
            stop(reason: .lowBattery)
        } else {
            objectWillChange.send()
        }
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = String(
                format: localized("error.launchAtLogin"),
                error.localizedDescription
            )
        }
    }

    private enum Keys {
        static let selectedMode = "selectedMode"
        static let selectedDuration = "selectedDuration"
        static let stopOnLowBattery = "stopOnLowBattery"
        static let lowBatteryThreshold = "lowBatteryThreshold"
        static let requireACPower = "requireACPower"
        static let launchAtLogin = "launchAtLogin"
    }
}
