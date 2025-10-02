//
//  RestfulApiService.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

protocol RestfulApiService {
    func getAllObjects() async throws -> [Device]
    func getObject(id: String) async throws -> Device
    func createObject(device: CreateDeviceRequest) async throws -> Device
    func updateObject(id: String, device: UpdateDeviceRequest) async throws -> Device
    func patchObject(id: String, device: UpdateDeviceRequest) async throws -> Device
    func deleteObject(id: String) async throws
}

class RestfulApiServiceImpl: RestfulApiService {
    private let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = HTTPClient()) {
        self.httpClient = httpClient
    }

    func getAllObjects() async throws -> [Device] {
        let request = HTTPRequest.get(url: RestfulAPIEndpoint.objects.fullURL)
        return try await httpClient.execute(request, responseType: [Device].self)
    }

    func getObject(id: String) async throws -> Device {
        let request = HTTPRequest.get(url: RestfulAPIEndpoint.object(id: id).fullURL)
        return try await httpClient.execute(request, responseType: Device.self)
    }

    func createObject(device: CreateDeviceRequest) async throws -> Device {
        let request = try HTTPRequest.post(url: RestfulAPIEndpoint.objects.fullURL, body: device)
        return try await httpClient.execute(request, responseType: Device.self)
    }

    func updateObject(id: String, device: UpdateDeviceRequest) async throws -> Device {
        let request = try HTTPRequest.put(url: RestfulAPIEndpoint.object(id: id).fullURL, body: device)
        return try await httpClient.execute(request, responseType: Device.self)
    }

    func patchObject(id: String, device: UpdateDeviceRequest) async throws -> Device {
        let request = try HTTPRequest.patch(url: RestfulAPIEndpoint.object(id: id).fullURL, body: device)
        return try await httpClient.execute(request, responseType: Device.self)
    }

    func deleteObject(id: String) async throws {
        let request = HTTPRequest.delete(url: RestfulAPIEndpoint.object(id: id).fullURL)
        try await httpClient.executeVoid(request)
    }
}