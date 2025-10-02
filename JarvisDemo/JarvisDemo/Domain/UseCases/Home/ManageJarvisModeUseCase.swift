//
//  ManageJarvisModeUseCase.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation
import Jarvis

protocol ManageJarvisModeUseCaseProtocol {
    func activateJarvis()
    func deactivateJarvis()
    func toggleJarvis() -> Bool
    func isJarvisActive() -> Bool
    func getJarvisConfiguration() -> JarvisConfig
}

class ManageJarvisModeUseCase: ManageJarvisModeUseCaseProtocol {

    func activateJarvis() {
        JarvisSDK.shared.activate()
    }

    func deactivateJarvis() {
        JarvisSDK.shared.deactivate()
    }

    func toggleJarvis() -> Bool {
        return JarvisSDK.shared.toggle()
    }

    func isJarvisActive() -> Bool {
        return JarvisSDK.shared.isActive
    }

    func getJarvisConfiguration() -> JarvisConfig {
        return JarvisSDK.shared.getConfiguration()
    }
}