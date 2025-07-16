import XCTest
@testable import Jarvis

final class JarvisTests: XCTestCase {
    
    func testJarvisConfiguration() throws {
        let jarvis = Jarvis.shared
        jarvis.configure()
        
        #if DEBUG
        XCTAssertTrue(jarvis.isDebugModeEnabled)
        #else
        XCTAssertFalse(jarvis.isDebugModeEnabled)
        #endif
    }
    
    func testNetworkInterceptionToggle() throws {
        let jarvis = Jarvis.shared
        
        jarvis.enableNetworkInterception()
        jarvis.disableNetworkInterception()
        
        // Test passes if no crashes occur
        XCTAssertTrue(true)
    }
}