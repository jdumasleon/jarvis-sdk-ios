//
//  JarvisDemoApp.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
import Jarvis
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct JarvisDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
