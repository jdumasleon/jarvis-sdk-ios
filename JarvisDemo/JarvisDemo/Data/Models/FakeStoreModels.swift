//
//  FakeStoreModels.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

// MARK: - Product Models

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}

struct CreateProductRequest: Codable {
    let title: String
    let price: Double
    let description: String
    let image: String
    let category: String
}

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let username: String
    let password: String
    let name: Name
    let address: Address
    let phone: String
}

struct Name: Codable {
    let firstname: String
    let lastname: String
}

struct Address: Codable {
    let city: String
    let street: String
    let number: Int
    let zipcode: String
    let geolocation: Geolocation
}

struct Geolocation: Codable {
    let lat: String
    let long: String
}

// MARK: - Cart Models

struct Cart: Codable, Identifiable {
    let id: Int
    let userId: Int
    let date: String
    let products: [CartProduct]
}

struct CartProduct: Codable {
    let productId: Int
    let quantity: Int
}

// MARK: - Auth Models

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}