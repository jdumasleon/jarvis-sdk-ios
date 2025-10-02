import Foundation
import os.log

/// Internal logger for Jarvis SDK
internal final class JarvisLogger {
    static let shared = JarvisLogger()

    private let logger: Logger
    private var isEnabled: Bool = false

    private init() {
        self.logger = Logger(subsystem: "com.jarvis.sdk", category: "Jarvis")
    }

    func configure(enableLogging: Bool) {
        self.isEnabled = enableLogging
    }

    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        logger.debug("[\(fileName):\(line)] \(function) - \(message)")
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        logger.info("[\(fileName):\(line)] \(function) - \(message)")
    }

    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        logger.warning("[\(fileName):\(line)] \(function) - \(message)")
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        logger.error("[\(fileName):\(line)] \(function) - \(message)")
    }
}