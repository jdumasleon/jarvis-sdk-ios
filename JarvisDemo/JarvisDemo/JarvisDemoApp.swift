//
//  JarvisDemoApp.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
import SwiftData
import Jarvis

@main
struct JarvisDemoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(
                    config: JarvisConfig.Builder()
                        .enableDebugLogging(true)
                        .enableShakeDetection(true)
                        .networkInspection { config in
                            config.enableNetworkLogging(true)
                                .enableRequestLogging(true)
                                .enableResponseLogging(true)
                        }
                        .preferences { config in
                            config.enableUserDefaultsMonitoring(true)
                        }
                        .build()
                )
        }
        .modelContainer(sharedModelContainer)
    }
}
