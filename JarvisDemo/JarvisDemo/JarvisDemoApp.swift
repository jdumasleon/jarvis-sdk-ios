//
//  JarvisDemoApp.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
// TODO: Enable Jarvis SDK integration once package dependencies are properly resolved in Xcode
// import Jarvis

@main
struct JarvisDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // TODO: Uncomment once Jarvis SDK module is available
            /*
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
            */
        }
    }
}
