import AppKit
import SwiftUI

struct OnboardingView: View {
    let onComplete: (Bool) -> Void

    @State private var page = 0
    @State private var hideOnFutureLaunches = false

    private let pageCount = 3

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "cat.fill")
                    .foregroundStyle(.red)
                    .font(.title2)

                Text("KeepCat")
                    .font(.headline)

                Spacer()

                Text("\(page + 1) / \(pageCount)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            OnboardingPreview(page: page)
                .padding(.horizontal, 28)
                .padding(.top, 24)

            VStack(spacing: 9) {
                Text("onboarding.page.\(page + 1).title", bundle: .module)
                    .font(.title2.weight(.semibold))

                Text("onboarding.page.\(page + 1).detail", bundle: .module)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 38)
            .padding(.top, 22)

            Spacer(minLength: 20)

            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? Color.red : Color.secondary.opacity(0.25))
                        .frame(width: index == page ? 20 : 6, height: 6)
                }
            }

            HStack(spacing: 16) {
                Toggle("onboarding.hideOnFutureLaunches", isOn: $hideOnFutureLaunches)
                    .toggleStyle(.checkbox)
                    .font(.subheadline)

                Spacer()

                Button {
                    page -= 1
                } label: {
                    Text("onboarding.back", bundle: .module)
                }
                .disabled(page == 0)

                Button {
                    if page == pageCount - 1 {
                        onComplete(hideOnFutureLaunches)
                    } else {
                        page += 1
                    }
                } label: {
                    Text(
                        page == pageCount - 1 ? "onboarding.done" : "onboarding.next",
                        bundle: .module
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut(.defaultAction)
            }
            .padding(24)
        }
        .frame(width: 600, height: 540)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct OnboardingPreview: View {
    let page: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))

            switch page {
            case 0:
                menuBarPreview
            case 1:
                menuPanelPreview
            default:
                sessionPreview
            }
        }
        .frame(height: 205)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary.opacity(0.08))
        }
    }

    private var menuBarPreview: some View {
        VStack(spacing: 20) {
            HStack(spacing: 11) {
                Spacer()
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
                Image(systemName: "magnifyingglass")
                ZStack {
                    Circle().fill(Color.red)
                    Image(systemName: "cat.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 19, weight: .semibold))
                }
                .frame(width: 34, height: 34)
                .overlay(alignment: .bottom) {
                    Image(systemName: "arrow.up")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.red)
                        .offset(y: 34)
                }
                .padding(.horizontal, 8)
                Image(systemName: "controlcenter")
                Spacer().frame(width: 12)
            }
            .font(.system(size: 17, weight: .medium))
            .padding(.vertical, 11)
            .background(.bar, in: RoundedRectangle(cornerRadius: 7))

            Text("onboarding.visual.menuBar", bundle: .module)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }

    private var menuPanelPreview: some View {
        HStack(spacing: 30) {
            Image(systemName: "arrow.right")
                .font(.title2.weight(.bold))
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cat.fill")
                        .foregroundStyle(.red)
                        .font(.title)
                    VStack(alignment: .leading, spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primary.opacity(0.75))
                            .frame(width: 115, height: 10)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.35))
                            .frame(width: 78, height: 7)
                    }
                    Spacer()
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .padding(9)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 6))
                }

                Divider()

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.18))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.12))
                }
                .frame(height: 28)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.18))
                    .frame(width: 180, height: 8)
            }
            .padding(17)
            .frame(width: 300)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.12), radius: 7, y: 3)
        }
    }

    private var sessionPreview: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 15) {
                Label("onboarding.visual.session", systemImage: "timer")
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 7) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.red.opacity(0.2))
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.secondary.opacity(0.14))
                }
                .frame(width: 205, height: 32)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 165, height: 9)
            }

            VStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.red, in: Circle())

                Text("onboarding.visual.start", bundle: .module)
                    .font(.caption.weight(.medium))
            }
        }
    }
}
