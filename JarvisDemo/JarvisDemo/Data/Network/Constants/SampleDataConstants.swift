//
//  SampleDataConstants.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

struct SampleDataConstants {

    // MARK: - Product Sample Data

    static let sampleProductNames = [
        "iPhone 15 Pro", "MacBook Pro M3", "AirPods Pro", "Apple Watch Ultra",
        "iPad Air", "Samsung Galaxy S24", "Dell XPS 13", "Sony WH-1000XM5",
        "Microsoft Surface Pro", "Google Pixel 8", "Nintendo Switch",
        "Tesla Model Y", "Canon EOS R5", "Bose QuietComfort", "Dyson V15"
    ]

    static let sampleProductCategories = [
        "electronics", "clothing", "books", "home", "sports",
        "automotive", "beauty", "toys", "jewelry", "music"
    ]

    static let sampleProductImages = [
        "https://i.pravatar.cc/150?img=1",
        "https://i.pravatar.cc/150?img=2",
        "https://i.pravatar.cc/150?img=3",
        "https://i.pravatar.cc/150?img=4",
        "https://i.pravatar.cc/150?img=5"
    ]

    // MARK: - Device Sample Data

    static let sampleDeviceNames = [
        "iPhone 15 Pro Max", "MacBook Pro 16\"", "iPad Pro 12.9\"",
        "Apple Watch Series 9", "Samsung Galaxy S24 Ultra", "Dell XPS 15",
        "HP Spectre x360", "Lenovo ThinkPad X1", "Microsoft Surface Laptop",
        "Google Pixel 8 Pro", "OnePlus 12", "Nothing Phone 2"
    ]

    static let sampleCPUModels = [
        "Apple M3 Pro", "Intel Core i7-13700H", "AMD Ryzen 7 7840HS",
        "Apple A17 Pro", "Snapdragon 8 Gen 3", "Intel Core i5-1340P",
        "AMD Ryzen 5 7640U", "Apple M2", "Qualcomm Snapdragon 8cx"
    ]

    static let sampleHardDiskSizes = [
        "128 GB", "256 GB", "512 GB", "1 TB", "2 TB", "4 TB"
    ]

    static let sampleColors = [
        "Space Black", "Silver", "Gold", "Deep Purple", "Blue",
        "Green", "Pink", "Yellow", "Red", "White", "Midnight",
        "Starlight", "Product Red", "Alpine Green", "Sierra Blue"
    ]

    // MARK: - User Sample Data

    static let sampleUsernames = [
        "john_doe", "jane_smith", "alex_wilson", "sarah_connor",
        "mike_johnson", "emma_brown", "david_lee", "lisa_garcia",
        "chris_martinez", "anna_taylor", "kevin_anderson", "maria_rodriguez"
    ]

    static let sampleFirstNames = [
        "John", "Jane", "Alex", "Sarah", "Mike", "Emma",
        "David", "Lisa", "Chris", "Anna", "Kevin", "Maria",
        "Robert", "Jennifer", "Michael", "Jessica", "William", "Ashley"
    ]

    static let sampleLastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
        "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez",
        "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore"
    ]

    static let sampleCities = [
        "New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
        "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose",
        "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte"
    ]

    static let sampleStreets = [
        "Main St", "Oak Ave", "Pine Rd", "Maple Dr", "Cedar Ln",
        "Elm St", "Park Ave", "First St", "Second St", "Third St",
        "Broadway", "Washington St", "Lincoln Ave", "Jefferson Rd"
    ]

    // MARK: - Authentication Sample Data

    static let sampleCredentials = [
        LoginRequest(username: "mor_2314", password: "83r5^_"),
        LoginRequest(username: "johnd", password: "m38rmF$"),
        LoginRequest(username: "elmich", password: "kev02937@"),
        LoginRequest(username: "cmichael", password: "cmichael"),
        LoginRequest(username: "david_r", password: "3478*#54"),
        LoginRequest(username: "kate_h", password: "kfejk@*_")
    ]

    // MARK: - Price Ranges

    static let productPriceRange: ClosedRange<Double> = 9.99...2999.99
    static let devicePriceRange: ClosedRange<Double> = 199.99...4999.99

    // MARK: - Year Ranges

    static let deviceYearRange: ClosedRange<Int> = 2020...2025

    // MARK: - Random Generators

    static func randomProductName() -> String {
        return sampleProductNames.randomElement() ?? "Unknown Product"
    }

    static func randomDeviceName() -> String {
        return sampleDeviceNames.randomElement() ?? "Unknown Device"
    }

    static func randomCategory() -> String {
        return sampleProductCategories.randomElement() ?? "electronics"
    }

    static func randomImage() -> String {
        return sampleProductImages.randomElement() ?? "https://i.pravatar.cc/150"
    }

    static func randomCPUModel() -> String {
        return sampleCPUModels.randomElement() ?? "Unknown CPU"
    }

    static func randomHardDiskSize() -> String {
        return sampleHardDiskSizes.randomElement() ?? "256 GB"
    }

    static func randomColor() -> String {
        return sampleColors.randomElement() ?? "Silver"
    }

    static func randomCredentials() -> LoginRequest {
        return sampleCredentials.randomElement() ?? LoginRequest(username: "demo", password: "demo")
    }
}