import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @Environment(\.openSettings) private var openSettings
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            statusHeader
            Divider()
            controls
            Divider()
            footer
        }
        .frame(width: 340)
        .background(Color(nsColor: .windowBackgroundColor))
        .alert(
            Text("error.title", bundle: .module),
            isPresented: errorBinding
        ) {
            Button {
                appState.dismissError()
            } label: {
                Text("action.ok", bundle: .module)
            }
        } message: {
            Text(appState.errorMessage ?? "")
        }
    }

    private var statusHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(appState.isKeepingAwake ? Color.red : Color.secondary.opacity(0.12))

                Image(systemName: appState.isKeepingAwake ? "cat.fill" : "cat")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(appState.isKeepingAwake ? .white : .secondary)
                    .accessibilityHidden(true)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(
                    appState.isKeepingAwake ? "status.awake" : "status.sleeping",
                    bundle: .module
                )
                .font(.system(size: 17, weight: .semibold))

                if appState.isKeepingAwake {
                    Text(appState.remainingTimeDescription)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                } else {
                    Text("status.ready", bundle: .module)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                appState.toggleSession()
            } label: {
                Image(systemName: appState.isKeepingAwake ? "stop.fill" : "play.fill")
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
            .help(
                Text(
                    appState.isKeepingAwake ? "action.stop" : "action.start",
                    bundle: .module
                )
            )
        }
        .padding(16)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("mode.title", bundle: .module)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker(
                    String(localized: "mode.title", bundle: .module),
                    selection: $appState.selectedMode
                ) {
                    ForEach(AwakeMode.allCases) { mode in
                        Label {
                            Text(appState.localized(mode.titleKey))
                        } icon: {
                            Image(systemName: mode.symbolName)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .disabled(appState.isKeepingAwake)

                Text(appState.localized(appState.selectedMode.detailKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Label {
                    Text("duration.title", bundle: .module)
                } icon: {
                    Image(systemName: "timer")
                }

                Spacer()

                Picker(
                    String(localized: "duration.title", bundle: .module),
                    selection: $appState.selectedDuration
                ) {
                    ForEach(SessionDuration.allCases) { duration in
                        Text(appState.localized(duration.titleKey))
                            .tag(duration)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .disabled(appState.isKeepingAwake)
            }

            if let stopReasonText {
                Label {
                    Text(stopReasonText)
                } icon: {
                    Image(systemName: "info.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }

    private var footer: some View {
        HStack {
            Button {
                openSettings()
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help(Text("action.settings", bundle: .module))

            Spacer()

            Text("KeepCat")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .help(Text("action.quit", bundle: .module))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { appState.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    appState.dismissError()
                }
            }
        )
    }

    private var stopReasonText: String? {
        guard !appState.isKeepingAwake, let reason = appState.lastStopReason else {
            return nil
        }

        switch reason {
        case .user:
            return nil
        case .timerFinished:
            return appState.localized("stopReason.timerFinished")
        case .lowBattery:
            return appState.localized("stopReason.lowBattery")
        case .disconnectedFromPower:
            return appState.localized("stopReason.disconnectedFromPower")
        case .systemError:
            return appState.localized("stopReason.systemError")
        }
    }
}
