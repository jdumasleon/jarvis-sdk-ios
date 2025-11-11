Pod::Spec.new do |spec|
  spec.name         = "JarvisSDK"
  spec.version = "1.2.0"
  spec.summary      = "Jarvis Mobile SDK for iOS - Network Inspection & Debugging"
  spec.description  = <<-DESC
                      Jarvis SDK is a comprehensive mobile debugging and network inspection tool for iOS applications.
                      Features include:
                      - Real-time network request monitoring
                      - Performance metrics tracking (CPU, Memory, FPS)
                      - Request/Response inspection with JSON formatting
                      - SharedPreferences/UserDefaults viewer
                      - Dashboard with analytics and insights
                      - SwiftUI-based modern interface
                      - UIKit integration support
                      DESC

  spec.homepage     = "https://github.com/jdumasleon/jarvis-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Jo Dumas" => "jdumasleon@gmail.com" }

  spec.platform     = :ios, "17.0"
  spec.swift_version = "5.9"

  spec.source       = {
    :git => "https://github.com/jdumasleon/jarvis-sdk-ios.git",
    :tag => "#{spec.version}"
  }

  # Main module
  spec.default_subspec = "Core"

  # Core module (required)
  spec.subspec "Core" do |core|
    core.source_files = [
      "JarvisSDK/Sources/Core/**/*.swift",
      "JarvisSDK/Sources/Jarvis/**/*.swift"
    ]
    core.resources = [
      "JarvisSDK/Sources/Resources/**/*.xcassets"
    ]
    core.dependency "JarvisSDK/DesignSystem"
  end

  # Design System module
  spec.subspec "DesignSystem" do |ds|
    ds.source_files = "../JarvisDesignSystem/Sources/DesignSystem/**/*.swift"
    ds.resources = "../JarvisDesignSystem/Sources/DesignSystem/Resources/**/*.xcassets"
  end

  # Inspector feature module (optional)
  spec.subspec "Inspector" do |inspector|
    inspector.source_files = "JarvisSDK/Sources/Inspector/**/*.swift"
    inspector.dependency "JarvisSDK/Core"
  end

  # Preferences feature module (optional)
  spec.subspec "Preferences" do |prefs|
    prefs.source_files = "JarvisSDK/Sources/Preferences/**/*.swift"
    prefs.dependency "JarvisSDK/Core"
  end

  spec.frameworks = "Foundation", "UIKit", "SwiftUI", "Combine", "Charts"
  spec.requires_arc = true

  # Compiler flags
  spec.pod_target_xcconfig = {
    "SWIFT_VERSION" => "5.9",
    "IPHONEOS_DEPLOYMENT_TARGET" => "17.0"
  }
end
