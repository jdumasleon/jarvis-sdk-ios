//
//  DemoApiRepository.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

// MARK: - API Method Definitions

enum APIMethodType: String, CaseIterable {
    // FakeStore API Methods
    case getAllProducts = "getAllProducts"
    case getProduct = "getProduct"
    case getProductsWithLimit = "getProductsWithLimit"
    case getAllCategories = "getAllCategories"
    case createProduct = "createProduct"
    case getAllCarts = "getAllCarts"
    case getAllUsers = "getAllUsers"
    case login = "login"

    // Restful API Methods
    case getAllObjects = "getAllObjects"
    case getObject = "getObject"
    case createObject = "createObject"
    case updateObject = "updateObject"
    case patchObject = "patchObject"
    case deleteObject = "deleteObject"

    var isFakeStoreMethod: Bool {
        switch self {
        case .getAllProducts, .getProduct, .getProductsWithLimit, .getAllCategories,
             .createProduct, .getAllCarts, .getAllUsers, .login:
            return true
        case .getAllObjects, .getObject, .createObject, .updateObject, .patchObject, .deleteObject:
            return false
        }
    }
}

// MARK: - Repository Protocol

protocol DemoApiRepositoryProtocol {
    func performRandomApiCall() async -> ApiCallResult
    func performInitialApiCalls(numberOfCalls: Int) async -> [ApiCallResult]
    func performRefreshApiCalls(numberOfCalls: Int) async -> [ApiCallResult]
}

// MARK: - Repository Implementation

class DemoApiRepository: DemoApiRepositoryProtocol {
    private let fakeStoreApi: FakeStoreApiService
    private let restfulApi: RestfulApiService

    // Configuration
    private let fakeStoreMethods: [APIMethodType] = [
        .getAllProducts, .getProduct, .getProductsWithLimit, .getAllCategories,
        .createProduct, .getAllCarts, .getAllUsers, .login
    ]

    private let restfulApiMethods: [APIMethodType] = [
        .getAllObjects, .getObject, .createObject, .updateObject, .patchObject, .deleteObject
    ]

    private let networkDelayRange: ClosedRange<Double> = 0.2...1.5

    init(
        fakeStoreApi: FakeStoreApiService = FakeStoreApiServiceImpl(),
        restfulApi: RestfulApiService = RestfulApiServiceImpl()
    ) {
        self.fakeStoreApi = fakeStoreApi
        self.restfulApi = restfulApi
    }

    func performRandomApiCall() async -> ApiCallResult {
        let isRestfulApi = Bool.random()
        let startTime = currentTimeMillis()

        do {
            if isRestfulApi {
                return await performRandomRestfulApiCall(startTime: startTime)
            } else {
                return await performRandomFakeStoreApiCall(startTime: startTime)
            }
        } catch {
            return createErrorResult(
                baseURL: isRestfulApi ? APIConstants.restfulApiBaseURL : APIConstants.fakeStoreBaseURL,
                startTime: startTime,
                error: error
            )
        }
    }

    func performInitialApiCalls(numberOfCalls: Int = Int.random(in: 10...20)) async -> [ApiCallResult] {
        await withTaskGroup(of: ApiCallResult.self, returning: [ApiCallResult].self) { group in
            for _ in 0..<numberOfCalls {
                group.addTask {
                    await self.performRandomApiCall()
                }
            }

            var results: [ApiCallResult] = []
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.startTime > $1.startTime }
        }
    }

    func performRefreshApiCalls(numberOfCalls: Int = 3) async -> [ApiCallResult] {
        await withTaskGroup(of: ApiCallResult.self, returning: [ApiCallResult].self) { group in
            for _ in 0..<numberOfCalls {
                group.addTask {
                    await self.performRandomApiCall()
                }
            }

            var results: [ApiCallResult] = []
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.startTime > $1.startTime }
        }
    }

    // MARK: - Private Methods

    private func performRandomFakeStoreApiCall(startTime: Int64) async -> ApiCallResult {
        await simulateNetworkDelay()

        let method = fakeStoreMethods.randomElement()!

        do {
            switch method {
            case .getAllProducts:
                _ = try await fakeStoreApi.getAllProducts()
                return createSuccessResult(
                    url: FakeStoreEndpoint.products.fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .getProduct:
                let productId = Int.random(in: 1...20)
                _ = try await fakeStoreApi.getProduct(id: productId)
                return createSuccessResult(
                    url: FakeStoreEndpoint.product(id: productId).fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .getProductsWithLimit:
                let limit = Int.random(in: 1...10)
                _ = try await fakeStoreApi.getProductsWithLimit(limit: limit)
                return createSuccessResult(
                    url: FakeStoreEndpoint.productsWithLimit(limit: limit).fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .getAllCategories:
                _ = try await fakeStoreApi.getAllCategories()
                return createSuccessResult(
                    url: FakeStoreEndpoint.categories.fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .createProduct:
                let product = generateSampleProduct()
                _ = try await fakeStoreApi.createProduct(product: product)
                return createSuccessResult(
                    url: FakeStoreEndpoint.products.fullURL,
                    method: "POST",
                    startTime: startTime,
                    statusCode: 201
                )

            case .getAllCarts:
                _ = try await fakeStoreApi.getAllCarts()
                return createSuccessResult(
                    url: FakeStoreEndpoint.carts.fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .getAllUsers:
                _ = try await fakeStoreApi.getAllUsers()
                return createSuccessResult(
                    url: FakeStoreEndpoint.users.fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .login:
                let credentials = SampleDataConstants.randomCredentials()
                _ = try await fakeStoreApi.login(loginRequest: credentials)
                return createSuccessResult(
                    url: FakeStoreEndpoint.login.fullURL,
                    method: "POST",
                    startTime: startTime
                )

            default:
                throw HTTPError.invalidURL("Unknown FakeStore method: \\(method)")
            }
        } catch {
            return createErrorResult(
                baseURL: APIConstants.fakeStoreBaseURL,
                startTime: startTime,
                error: error
            )
        }
    }

    private func performRandomRestfulApiCall(startTime: Int64) async -> ApiCallResult {
        await simulateNetworkDelay()

        let method = restfulApiMethods.randomElement()!

        do {
            switch method {
            case .getAllObjects:
                _ = try await restfulApi.getAllObjects()
                return createSuccessResult(
                    url: RestfulAPIEndpoint.objects.fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .getObject:
                let objectId = String(Int.random(in: 1...50))
                _ = try await restfulApi.getObject(id: objectId)
                return createSuccessResult(
                    url: RestfulAPIEndpoint.object(id: objectId).fullURL,
                    method: "GET",
                    startTime: startTime
                )

            case .createObject:
                let device = generateSampleCreateDevice()
                _ = try await restfulApi.createObject(device: device)
                return createSuccessResult(
                    url: RestfulAPIEndpoint.objects.fullURL,
                    method: "POST",
                    startTime: startTime,
                    statusCode: 201
                )

            case .updateObject:
                let objectId = String(Int.random(in: 1...50))
                let device = generateSampleUpdateDevice()
                _ = try await restfulApi.updateObject(id: objectId, device: device)
                return createSuccessResult(
                    url: RestfulAPIEndpoint.object(id: objectId).fullURL,
                    method: "PUT",
                    startTime: startTime
                )

            case .patchObject:
                let objectId = String(Int.random(in: 1...50))
                let device = generateSampleUpdateDevice(partialUpdate: true)
                _ = try await restfulApi.patchObject(id: objectId, device: device)
                return createSuccessResult(
                    url: RestfulAPIEndpoint.object(id: objectId).fullURL,
                    method: "PATCH",
                    startTime: startTime
                )

            case .deleteObject:
                let objectId = String(Int.random(in: 1...50))
                try await restfulApi.deleteObject(id: objectId)
                return createSuccessResult(
                    url: RestfulAPIEndpoint.object(id: objectId).fullURL,
                    method: "DELETE",
                    startTime: startTime
                )

            default:
                throw HTTPError.invalidURL("Unknown Restful method: \\(method)")
            }
        } catch {
            return createErrorResult(
                baseURL: APIConstants.restfulApiBaseURL,
                startTime: startTime,
                error: error
            )
        }
    }

    // MARK: - Helper Methods

    private func simulateNetworkDelay() async {
        let delay = Double.random(in: networkDelayRange)
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    private func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    private func createSuccessResult(
        url: String,
        method: String,
        startTime: Int64,
        statusCode: Int = 200
    ) -> ApiCallResult {
        let endTime = currentTimeMillis()
        let host = URL(string: url)?.host ?? url

        return ApiCallResult(
            url: url,
            host: host,
            method: method,
            startTime: startTime,
            endTime: endTime,
            isSuccess: true,
            statusCode: statusCode,
            error: nil
        )
    }

    private func createErrorResult(
        baseURL: String,
        startTime: Int64,
        error: Error
    ) -> ApiCallResult {
        let endTime = currentTimeMillis()
        let host = URL(string: baseURL)?.host ?? baseURL

        let statusCode: Int
        let errorMessage: String

        if let httpError = error as? HTTPError {
            switch httpError {
            case .statusCode(let code, let message):
                statusCode = code
                errorMessage = message ?? httpError.localizedDescription
            case .timeout:
                statusCode = 408
                errorMessage = "Request Timeout"
            case .networkError:
                statusCode = 0
                errorMessage = "Network Error"
            default:
                statusCode = 500
                errorMessage = httpError.localizedDescription
            }
        } else {
            statusCode = 500
            errorMessage = error.localizedDescription
        }

        return ApiCallResult(
            url: baseURL,
            host: host,
            method: "GET",
            startTime: startTime,
            endTime: endTime,
            isSuccess: false,
            statusCode: statusCode,
            error: errorMessage
        )
    }

    // MARK: - Sample Data Generators

    private func generateSampleProduct() -> CreateProductRequest {
        return CreateProductRequest(
            title: SampleDataConstants.randomProductName(),
            price: Double.random(in: SampleDataConstants.productPriceRange),
            description: "Sample product for demo purposes",
            image: SampleDataConstants.randomImage(),
            category: SampleDataConstants.randomCategory()
        )
    }

    private func generateSampleCreateDevice() -> CreateDeviceRequest {
        return CreateDeviceRequest(
            name: SampleDataConstants.randomDeviceName(),
            data: DeviceData(
                year: Int.random(in: SampleDataConstants.deviceYearRange),
                price: Double.random(in: SampleDataConstants.devicePriceRange),
                cpuModel: SampleDataConstants.randomCPUModel(),
                hardDiskSize: SampleDataConstants.randomHardDiskSize(),
                color: SampleDataConstants.randomColor()
            )
        )
    }

    private func generateSampleUpdateDevice(partialUpdate: Bool = false) -> UpdateDeviceRequest {
        return UpdateDeviceRequest(
            name: SampleDataConstants.randomDeviceName(),
            data: partialUpdate ? nil : DeviceData(
                year: Int.random(in: SampleDataConstants.deviceYearRange),
                price: Double.random(in: SampleDataConstants.devicePriceRange),
                cpuModel: SampleDataConstants.randomCPUModel(),
                hardDiskSize: SampleDataConstants.randomHardDiskSize(),
                color: SampleDataConstants.randomColor()
            )
        )
    }
}
