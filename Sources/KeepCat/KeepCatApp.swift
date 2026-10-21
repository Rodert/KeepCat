import AppKit
import SwiftUI

@main
struct KeepCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isKeepingAwake ? "cat.fill" : "cat")
                .accessibilityLabel(Text(appState.statusLabel))
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        DispatchQueue.main.async {
            self.showOnboardingIfNeeded()
        }
    }

    private func showOnboardingIfNeeded() {
        guard OnboardingPreference.shouldPresent() else { return }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 540),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "onboarding.windowTitle", bundle: .module)
        window.isReleasedWhenClosed = false
        window.center()

        window.contentView = NSHostingView(
            rootView: OnboardingView { [weak self] hideOnFutureLaunches in
                if hideOnFutureLaunches {
                    OnboardingPreference.hideOnFutureLaunches()
                }
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
            }
        )

        onboardingWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
