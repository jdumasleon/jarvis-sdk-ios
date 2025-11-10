import Testing
@testable import JarvisSDK

struct JarvisConfigBuilderTests {
    @Test func builderProducesCustomizedConfiguration() {
        let config = JarvisConfig
            .builder()
            .enableDebugLogging(true)
            .enableShakeDetection(false)
            .networkInspection(
                NetworkInspectionConfig(
                    enableNetworkLogging: false,
                    maxRequestBodySize: 1024,
                    maxResponseBodySize: 2048,
                    enableRequestLogging: false,
                    enableResponseLogging: true,
                    excludeHosts: ["private.example.com"],
                    includeOnlyHosts: ["api.example.com"]
                )
            )
            .build()

        #expect(config.enableDebugLogging)
        #expect(!config.enableShakeDetection)
        #expect(!config.networkInspection.enableNetworkLogging)
        #expect(config.networkInspection.maxRequestBodySize == 1024)
        #expect(config.networkInspection.excludeHosts == ["private.example.com"])
        #expect(config.networkInspection.includeOnlyHosts == ["api.example.com"])
    }
}
