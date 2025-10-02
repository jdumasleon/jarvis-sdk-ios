//
//  ManageJarvisModeUseCase.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation
// TODO: Enable once Jarvis SDK module is available
// import Jarvis

protocol ManageJarvisModeUseCaseProtocol {
    func activateJarvis()
    func deactivateJarvis()
    func toggleJarvis() -> Bool
    func isJarvisActive() -> Bool
    func getJarvisConfiguration() -> JarvisConfig
}

class ManageJarvisModeUseCase: ManageJarvisModeUseCaseProtocol {

    func activateJarvis() {
        // TODO: Implement once JarvisSDK is available
        // JarvisSDK.shared.activate()
        print("Jarvis activated (stub)")
    }

    func deactivateJarvis() {
        // TODO: Implement once JarvisSDK is available
        // JarvisSDK.shared.deactivate()
        print("Jarvis deactivated (stub)")
    }

    func toggleJarvis() -> Bool {
        // TODO: Implement once JarvisSDK is available
        // return JarvisSDK.shared.toggle()
        print("Jarvis toggled (stub)")
        return true
    }

    func isJarvisActive() -> Bool {
        // TODO: Implement once JarvisSDK is available
        // return JarvisSDK.shared.isActive
        return false
    }

    func getJarvisConfiguration() -> JarvisConfig {
        // TODO: Implement once JarvisSDK is available
        // return JarvisSDK.shared.getConfiguration()
        return JarvisConfig(
            enableDebugLogging: true,
            enableShakeDetection: true,
            networkInspection: NetworkInspectionConfig(
                enableNetworkLogging: true,
                enableRequestLogging: true,
                enableResponseLogging: true
            ),
            preferences: PreferencesConfig(
                enableUserDefaultsMonitoring: true
            )
        )
    }
}