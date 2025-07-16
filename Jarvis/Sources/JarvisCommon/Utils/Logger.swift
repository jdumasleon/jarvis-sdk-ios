import Foundation
import os.log

public final class JarvisLogger {
    public static let shared = JarvisLogger()
    
    private let logger = Logger(subsystem: "com.jarvis.sdk", category: "JarvisSDK")
    
    private init() {}
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        logger.debug("[\(fileName(from: file)):\(line)] \(function) - \(message)")
        #endif
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("[\(fileName(from: file)):\(line)] \(function) - \(message)")
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning("[\(fileName(from: file)):\(line)] \(function) - \(message)")
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.error("[\(fileName(from: file)):\(line)] \(function) - \(message)")
    }
    
    private func fileName(from filePath: String) -> String {
        return URL(fileURLWithPath: filePath).lastPathComponent
    }
}