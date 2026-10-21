import Foundation

enum OnboardingPreference {
    private static let hideOnboardingKey = "hideOnboarding"

    static func shouldPresent(defaults: UserDefaults = .standard) -> Bool {
        !defaults.bool(forKey: hideOnboardingKey)
    }

    static func hideOnFutureLaunches(defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: hideOnboardingKey)
    }
}
