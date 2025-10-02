//
//  APIConstants.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

// MARK: - Base URLs

struct APIConstants {
    static let fakeStoreBaseURL = "https://fakestoreapi.com"
    static let restfulApiBaseURL = "https://api.restful-api.dev"
}

// MARK: - FakeStore API Endpoints

enum FakeStoreEndpoint {
    case products
    case product(id: Int)
    case productsWithLimit(limit: Int)
    case productsWithSort(sort: String)
    case categories
    case productsByCategory(category: String)
    case carts
    case cart(id: Int)
    case cartsWithLimit(limit: Int)
    case cartsWithSort(sort: String)
    case cartsWithDateRange(startDate: String, endDate: String)
    case userCarts(userId: Int)
    case users
    case user(id: Int)
    case usersWithLimit(limit: Int)
    case usersWithSort(sort: String)
    case login

    var path: String {
        switch self {
        case .products:
            return "/products"
        case .product(let id):
            return "/products/\(id)"
        case .productsWithLimit(let limit):
            return "/products?limit=\(limit)"
        case .productsWithSort(let sort):
            return "/products?sort=\(sort)"
        case .categories:
            return "/products/categories"
        case .productsByCategory(let category):
            return "/products/category/\(category)"
        case .carts:
            return "/carts"
        case .cart(let id):
            return "/carts/\(id)"
        case .cartsWithLimit(let limit):
            return "/carts?limit=\(limit)"
        case .cartsWithSort(let sort):
            return "/carts?sort=\(sort)"
        case .cartsWithDateRange(let startDate, let endDate):
            return "/carts?startdate=\(startDate)&enddate=\(endDate)"
        case .userCarts(let userId):
            return "/carts/user/\(userId)"
        case .users:
            return "/users"
        case .user(let id):
            return "/users/\(id)"
        case .usersWithLimit(let limit):
            return "/users?limit=\(limit)"
        case .usersWithSort(let sort):
            return "/users?sort=\(sort)"
        case .login:
            return "/auth/login"
        }
    }

    var fullURL: String {
        return APIConstants.fakeStoreBaseURL + path
    }
}

// MARK: - Restful API Endpoints

enum RestfulAPIEndpoint {
    case objects
    case object(id: String)

    var path: String {
        switch self {
        case .objects:
            return "/objects"
        case .object(let id):
            return "/objects/\(id)"
        }
    }

    var fullURL: String {
        return APIConstants.restfulApiBaseURL + path
    }
}