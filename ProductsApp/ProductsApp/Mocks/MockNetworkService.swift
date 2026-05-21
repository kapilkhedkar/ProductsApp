//
//  MockNetworkService.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//
import Foundation

final class MockNetworkService: NetworkServiceProtocol {
    func fetchProducts(page: Int, limit: Int, category: String,
                       completion: @escaping (Result<ProductResponse, NetworkError>) -> Void) {
        
        // To simulate No Network
        completion(.failure(.noInternet))

        // To simulate empty data:
//         let empty = ProductResponse(data: [], pagination: Pagination(page: 1, limit: 10, total: 0))
//         completion(.success(empty))
        
        // To simulate API error
//        completion(.failure(.invalidResponse(statusCode: 404)))
    }
}
