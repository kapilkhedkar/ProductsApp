//
//  NetworkService.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//
import Foundation

enum NetworkError: LocalizedError {
    case noInternet
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection. Please check your network and try again."
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse(let code):
            return "Server returned an unexpected response (HTTP \(code))."
        case .decodingFailed(let err):
            return "Failed to parse the server response: \(err.localizedDescription)"
        case .unknown(let err):
            return err.localizedDescription
        }
    }

    var isNoInternet: Bool {
        if case .noInternet = self { return true }
        return false
    }
}

protocol NetworkServiceProtocol {
    func fetchProducts(page: Int,
                       limit: Int,
                       category: String,
                       completion: @escaping (Result<ProductResponse, NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    static let shared = NetworkService()

    private let session: URLSession
    private let baseURL = "https://fakeapi.net/products"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts(page: Int,
                       limit: Int,
                       category: String,
                       completion: @escaping (Result<ProductResponse, NetworkError>) -> Void) {

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "page",     value: "\(page)"),
            URLQueryItem(name: "limit",    value: "\(limit)"),
            URLQueryItem(name: "category", value: category)
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in

            
            if let error = error as NSError? {
                let networkError: NetworkError =
                    (error.domain == NSURLErrorDomain &&
                     error.code   == NSURLErrorNotConnectedToInternet)
                    ? .noInternet
                    : .unknown(error)
                DispatchQueue.main.async { completion(.failure(networkError)) }
                return
            }

            
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse(statusCode: http.statusCode)))
                }
                return
            }

            
            guard let data else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse(statusCode: -1))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error))) }
            }
        }
        task.resume()
    }
}
