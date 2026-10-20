import Foundation
import IOKit.pwr_mgt

final class SleepAssertionController {
    private var assertionID = IOPMAssertionID(0)

    var isActive: Bool {
        assertionID != 0
    }

    func start(mode: AwakeMode) throws {
        stop()

        let assertionType: CFString
        switch mode {
        case .allowDisplaySleep:
            assertionType = kIOPMAssertionTypePreventUserIdleSystemSleep as CFString
        case .keepDisplayOn:
            assertionType = kIOPMAssertionTypeNoDisplaySleep as CFString
        }

        var newAssertionID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "KeepCat active session" as CFString,
            &newAssertionID
        )

        guard result == kIOReturnSuccess else {
            throw SleepAssertionError.couldNotCreate(result)
        }

        assertionID = newAssertionID
    }

    func stop() {
        guard assertionID != 0 else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }

    deinit {
        stop()
    }
}

enum SleepAssertionError: LocalizedError {
    case couldNotCreate(IOReturn)

    var errorDescription: String? {
        switch self {
        case .couldNotCreate(let code):
            return "IOKit error \(code)"
        }
    }
}
