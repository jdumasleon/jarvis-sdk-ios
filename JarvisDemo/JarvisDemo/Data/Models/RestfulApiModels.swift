//
//  RestfulApiModels.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

// MARK: - Device Models

struct Device: Codable, Identifiable {
    let id: String
    let name: String
    let data: DeviceData?
}

struct DeviceData: Codable {
    let year: Int?
    let price: Double?
    let cpuModel: String?
    let hardDiskSize: String?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case year, price, color
        case cpuModel = "CPU model"
        case hardDiskSize = "Hard disk size"
    }
}

struct CreateDeviceRequest: Codable {
    let name: String
    let data: DeviceData?
}

struct UpdateDeviceRequest: Codable {
    let name: String?
    let data: DeviceData?
}