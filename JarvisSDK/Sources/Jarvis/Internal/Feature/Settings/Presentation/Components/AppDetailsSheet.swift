//
//  AppDetailsSheet.swift
//  JarvisSDK
//
//  Bottom sheet displaying detailed app information
//

import SwiftUI
import DesignSystem

/// Bottom sheet displaying detailed app and SDK information
struct AppDetailsSheet: View {
    let appInfo: SettingsAppInfo
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    VStack(spacing: DSSpacing.s) {
                        infoRow(label: "App Name", value: appInfo.hostAppInfo.appName)
                        Divider()
                        infoRow(label: "Version", value: appInfo.hostAppInfo.version)
                        Divider()
                        infoRow(label: "Build Number", value: appInfo.hostAppInfo.buildNumber)
                        Divider()
                        infoRow(label: "Bundle ID", value: appInfo.hostAppInfo.bundleIdentifier)

                        if let minOS = appInfo.hostAppInfo.minimumOSVersion {
                            Divider()
                            infoRow(label: "Minimum iOS", value: minOS)
                        }

                        if let targetOS = appInfo.hostAppInfo.targetOSVersion {
                            Divider()
                            infoRow(label: "Target iOS", value: targetOS)
                        }
                    }
                    .padding(DSSpacing.m)
                    .background(DSColor.Extra.white)
                    .cornerRadius(DSSpacing.m)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(DSSpacing.m)
            }
            .background(DSColor.Extra.background0)
            .navigationTitle("App Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                #endif
            }
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            DSText(
                label,
                style: .bodyMedium
            )

            Spacer()

            DSText(
                value,
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
        }
        .padding(.vertical, DSSpacing.xxxs)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("App Details Sheet") {
    AppDetailsSheet(
        appInfo: AppInfoMock.mockSettingsAppInfo,
        onDismiss: {}
    )
}
#endif
