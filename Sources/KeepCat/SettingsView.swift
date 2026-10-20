import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $appState.requireACPower) {
                    Text("settings.requireACPower", bundle: .module)
                }

                Toggle(isOn: $appState.stopOnLowBattery) {
                    Text("settings.stopOnLowBattery", bundle: .module)
                }

                if appState.stopOnLowBattery {
                    HStack {
                        Text("settings.batteryThreshold", bundle: .module)
                        Spacer()
                        Stepper(
                            "\(appState.lowBatteryThreshold)%",
                            value: $appState.lowBatteryThreshold,
                            in: 5...50,
                            step: 5
                        )
                        .frame(width: 125)
                    }
                }
            } header: {
                Text("settings.power", bundle: .module)
            }

            Section {
                Toggle(isOn: $appState.launchAtLogin) {
                    Text("settings.launchAtLogin", bundle: .module)
                }
            } header: {
                Text("settings.general", bundle: .module)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 290)
        .navigationTitle(Text("settings.title", bundle: .module))
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
}
