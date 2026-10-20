import XCTest
@testable import KeepCat

@MainActor
final class KeepCatTests: XCTestCase {
    func testDurationFormattingUnderOneHour() {
        let state = AppState(defaults: isolatedDefaults())
        XCTAssertEqual(state.formatDuration(65), "01:05")
    }

    func testDurationFormattingOverOneHour() {
        let state = AppState(defaults: isolatedDefaults())
        XCTAssertEqual(state.formatDuration(3_661), "1:01:01")
    }

    func testIndefiniteDurationHasNoInterval() {
        XCTAssertNil(SessionDuration.indefinitely.timeInterval)
    }

    private func isolatedDefaults() -> UserDefaults {
        let suiteName = "KeepCatTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
