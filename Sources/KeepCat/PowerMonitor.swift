import Foundation
import IOKit.ps

enum PowerMonitor {
    static func currentState() -> PowerState {
        guard
            let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let powerSources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef]
        else {
            return .unknown
        }

        for source in powerSources {
            guard
                let description = IOPSGetPowerSourceDescription(snapshot, source)?
                    .takeUnretainedValue() as? [String: Any]
            else {
                continue
            }

            let sourceState = description[kIOPSPowerSourceStateKey] as? String
            let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int
            let maximumCapacity = description[kIOPSMaxCapacityKey] as? Int

            let batteryPercentage: Int?
            if let currentCapacity, let maximumCapacity, maximumCapacity > 0 {
                batteryPercentage = Int(
                    (Double(currentCapacity) / Double(maximumCapacity) * 100).rounded()
                )
            } else {
                batteryPercentage = nil
            }

            return PowerState(
                isConnectedToAC: sourceState == kIOPSACPowerValue,
                batteryPercentage: batteryPercentage
            )
        }

        return .unknown
    }
}
