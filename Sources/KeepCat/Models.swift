import Foundation

enum AwakeMode: String, CaseIterable, Identifiable {
    case allowDisplaySleep
    case keepDisplayOn

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .allowDisplaySleep:
            return "mode.allowDisplaySleep"
        case .keepDisplayOn:
            return "mode.keepDisplayOn"
        }
    }

    var detailKey: String {
        switch self {
        case .allowDisplaySleep:
            return "mode.allowDisplaySleep.detail"
        case .keepDisplayOn:
            return "mode.keepDisplayOn.detail"
        }
    }

    var symbolName: String {
        switch self {
        case .allowDisplaySleep:
            return "moon.zzz"
        case .keepDisplayOn:
            return "sun.max.fill"
        }
    }
}

enum SessionDuration: Int, CaseIterable, Identifiable {
    case fifteenMinutes = 900
    case thirtyMinutes = 1_800
    case oneHour = 3_600
    case twoHours = 7_200
    case fourHours = 14_400
    case indefinitely = 0

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .fifteenMinutes:
            return "duration.15minutes"
        case .thirtyMinutes:
            return "duration.30minutes"
        case .oneHour:
            return "duration.1hour"
        case .twoHours:
            return "duration.2hours"
        case .fourHours:
            return "duration.4hours"
        case .indefinitely:
            return "duration.indefinitely"
        }
    }

    var timeInterval: TimeInterval? {
        self == .indefinitely ? nil : TimeInterval(rawValue)
    }
}

enum StopReason: Equatable {
    case user
    case timerFinished
    case lowBattery
    case disconnectedFromPower
    case systemError(String)
}

struct PowerState: Equatable {
    let isConnectedToAC: Bool
    let batteryPercentage: Int?

    static let unknown = PowerState(
        isConnectedToAC: false,
        batteryPercentage: nil
    )
}
