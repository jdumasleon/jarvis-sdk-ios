//
//  LoggingView.swift
//  JarvisSDK
//
//  Logging configuration view
//

import SwiftUI
import DesignSystem

/// View for configuring logging settings
public struct LoggingView: View {
    @State private var logLevel: String = "Info"
    @State private var enableFileLogging = false
    @State private var enableConsoleLogging = true

    private let logLevels = ["Verbose", "Debug", "Info", "Warning", "Error"]

    public init() {}

    public var body: some View {
        Form {
            Section(header: Text("Log Level")) {
                Picker("Log Level", selection: $logLevel) {
                    ForEach(logLevels, id: \.self) { level in
                        Text(level).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Output")) {
                Toggle("Console Logging", isOn: $enableConsoleLogging)
                Toggle("File Logging", isOn: $enableFileLogging)
            }

            Section(header: Text("Actions")) {
                Button("Clear Logs") {
                    // TODO: Implement log clearing
                }
                .foregroundColor(.red)

                Button("Export Logs") {
                    // TODO: Implement log export
                }
            }
        }
        .navigationTitle("Logging")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#if DEBUG
#Preview("Logging View") {
    NavigationView {
        LoggingView()
    }
}
#endif
