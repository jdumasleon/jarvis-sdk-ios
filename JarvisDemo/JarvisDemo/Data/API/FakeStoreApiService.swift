//
//  FakeStoreApiService.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import Foundation

protocol FakeStoreApiService {
    func getAllProducts() async throws -> [Product]
    func getProduct(id: Int) async throws -> Product
    func getProductsWithLimit(limit: Int) async throws -> [Product]
    func getProductsWithSort(sort: String) async throws -> [Product]
    func getAllCategories() async throws -> [String]
    func getProductsInCategory(category: String) async throws -> [Product]
    func createProduct(product: CreateProductRequest) async throws -> Product
    func updateProduct(id: Int, product: CreateProductRequest) async throws -> Product
    func deleteProduct(id: Int) async throws -> Product
    func getAllCarts() async throws -> [Cart]
    func getCart(id: Int) async throws -> Cart
    func getCartsWithLimit(limit: Int) async throws -> [Cart]
    func getCartsWithSort(sort: String) async throws -> [Cart]
    func getCartsWithDateRange(startDate: String, endDate: String) async throws -> [Cart]
    func getUserCarts(userId: Int) async throws -> [Cart]
    func createCart(cart: Cart) async throws -> Cart
    func updateCart(id: Int, cart: Cart) async throws -> Cart
    func deleteCart(id: Int) async throws -> Cart
    func getAllUsers() async throws -> [User]
    func getUser(id: Int) async throws -> User
    func getUsersWithLimit(limit: Int) async throws -> [User]
    func getUsersWithSort(sort: String) async throws -> [User]
    func createUser(user: User) async throws -> User
    func updateUser(id: Int, user: User) async throws -> User
    func deleteUser(id: Int) async throws -> User
    func login(loginRequest: LoginRequest) async throws -> LoginResponse
}

class FakeStoreApiServiceImpl: FakeStoreApiService {
    private let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol = HTTPClient()) {
        self.httpClient = httpClient
    }

    // MARK: - Products

    func getAllProducts() async throws -> [Product] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.products.fullURL)
        return try await httpClient.execute(request, responseType: [Product].self)
    }

    func getProduct(id: Int) async throws -> Product {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.product(id: id).fullURL)
        return try await httpClient.execute(request, responseType: Product.self)
    }

    func getProductsWithLimit(limit: Int) async throws -> [Product] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.productsWithLimit(limit: limit).fullURL)
        return try await httpClient.execute(request, responseType: [Product].self)
    }

    func getProductsWithSort(sort: String) async throws -> [Product] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.productsWithSort(sort: sort).fullURL)
        return try await httpClient.execute(request, responseType: [Product].self)
    }

    func getAllCategories() async throws -> [String] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.categories.fullURL)
        return try await httpClient.execute(request, responseType: [String].self)
    }

    func getProductsInCategory(category: String) async throws -> [Product] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.productsByCategory(category: category).fullURL)
        return try await httpClient.execute(request, responseType: [Product].self)
    }

    func createProduct(product: CreateProductRequest) async throws -> Product {
        let request = try HTTPRequest.post(url: FakeStoreEndpoint.products.fullURL, body: product)
        return try await httpClient.execute(request, responseType: Product.self)
    }

    func updateProduct(id: Int, product: CreateProductRequest) async throws -> Product {
        let request = try HTTPRequest.put(url: FakeStoreEndpoint.product(id: id).fullURL, body: product)
        return try await httpClient.execute(request, responseType: Product.self)
    }

    func deleteProduct(id: Int) async throws -> Product {
        let request = HTTPRequest.delete(url: FakeStoreEndpoint.product(id: id).fullURL)
        return try await httpClient.execute(request, responseType: Product.self)
    }

    // MARK: - Carts

    func getAllCarts() async throws -> [Cart] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.carts.fullURL)
        return try await httpClient.execute(request, responseType: [Cart].self)
    }

    func getCart(id: Int) async throws -> Cart {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.cart(id: id).fullURL)
        return try await httpClient.execute(request, responseType: Cart.self)
    }

    func getCartsWithLimit(limit: Int) async throws -> [Cart] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.cartsWithLimit(limit: limit).fullURL)
        return try await httpClient.execute(request, responseType: [Cart].self)
    }

    func getCartsWithSort(sort: String) async throws -> [Cart] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.cartsWithSort(sort: sort).fullURL)
        return try await httpClient.execute(request, responseType: [Cart].self)
    }

    func getCartsWithDateRange(startDate: String, endDate: String) async throws -> [Cart] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.cartsWithDateRange(startDate: startDate, endDate: endDate).fullURL)
        return try await httpClient.execute(request, responseType: [Cart].self)
    }

    func getUserCarts(userId: Int) async throws -> [Cart] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.userCarts(userId: userId).fullURL)
        return try await httpClient.execute(request, responseType: [Cart].self)
    }

    func createCart(cart: Cart) async throws -> Cart {
        let request = try HTTPRequest.post(url: FakeStoreEndpoint.carts.fullURL, body: cart)
        return try await httpClient.execute(request, responseType: Cart.self)
    }

    func updateCart(id: Int, cart: Cart) async throws -> Cart {
        let request = try HTTPRequest.put(url: FakeStoreEndpoint.cart(id: id).fullURL, body: cart)
        return try await httpClient.execute(request, responseType: Cart.self)
    }

    func deleteCart(id: Int) async throws -> Cart {
        let request = HTTPRequest.delete(url: FakeStoreEndpoint.cart(id: id).fullURL)
        return try await httpClient.execute(request, responseType: Cart.self)
    }

    // MARK: - Users

    func getAllUsers() async throws -> [User] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.users.fullURL)
        return try await httpClient.execute(request, responseType: [User].self)
    }

    func getUser(id: Int) async throws -> User {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.user(id: id).fullURL)
        return try await httpClient.execute(request, responseType: User.self)
    }

    func getUsersWithLimit(limit: Int) async throws -> [User] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.usersWithLimit(limit: limit).fullURL)
        return try await httpClient.execute(request, responseType: [User].self)
    }

    func getUsersWithSort(sort: String) async throws -> [User] {
        let request = HTTPRequest.get(url: FakeStoreEndpoint.usersWithSort(sort: sort).fullURL)
        return try await httpClient.execute(request, responseType: [User].self)
    }

    func createUser(user: User) async throws -> User {
        let request = try HTTPRequest.post(url: FakeStoreEndpoint.users.fullURL, body: user)
        return try await httpClient.execute(request, responseType: User.self)
    }

    func updateUser(id: Int, user: User) async throws -> User {
        let request = try HTTPRequest.put(url: FakeStoreEndpoint.user(id: id).fullURL, body: user)
        return try await httpClient.execute(request, responseType: User.self)
    }

    func deleteUser(id: Int) async throws -> User {
        let request = HTTPRequest.delete(url: FakeStoreEndpoint.user(id: id).fullURL)
        return try await httpClient.execute(request, responseType: User.self)
    }

    // MARK: - Auth

    func login(loginRequest: LoginRequest) async throws -> LoginResponse {
        let request = try HTTPRequest.post(url: FakeStoreEndpoint.login.fullURL, body: loginRequest)
        return try await httpClient.execute(request, responseType: LoginResponse.self)
    }
}