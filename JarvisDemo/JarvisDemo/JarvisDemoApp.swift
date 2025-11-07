//
//  JarvisDemoApp.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
import Jarvis
import JarvisPreferencesDomain

@main
struct JarvisDemoApp: App {
    init() {
        JarvisSDK.shared.initializeAsync()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK() 
        }
    }
}
