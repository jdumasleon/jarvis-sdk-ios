import SwiftUI
import Jarvis

@main
struct JarvisSdk: App {
    init() {
        Jarvis.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisShakeDetector()
        }
    }
}
