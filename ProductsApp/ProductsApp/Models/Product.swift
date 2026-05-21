//
//  Product.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import Foundation
 
struct ProductResponse: Codable {
    let data: [Product]
    let pagination: Pagination
}
 
struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    
    var nextPage: Int? {
        let totalPages = Int(ceil(Double(total) / Double(limit)))
        return page < totalPages ? page + 1 : nil
    }
}
 
struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let brand: String
    let stock: Int
    let image: String?
    let specs: [String: AnyCodable]?
    let rating: ProductRating?
 
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
 
    var formattedRating: String {
        guard let r = rating else { return "No rating" }
        return String(format: "%.1f ⭐  (%d reviews)", r.rate, r.count)
    }
 
    var imageURL: URL? {
        guard let image else { return nil }
        return URL(string: image)
    }
}
 
struct ProductRating: Codable {
    let rate: Double
    let count: Int
}
 
struct AnyCodable: Codable {
    let value: Any
 
    init(_ value: Any) { self.value = value }
 
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self)   { value = b; return }
        if let i = try? c.decode(Int.self)    { value = i; return }
        if let d = try? c.decode(Double.self) { value = d; return }
        if let s = try? c.decode(String.self) { value = s; return }
        value = ""
    }
 
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let b as Bool:   try c.encode(b)
        case let i as Int:    try c.encode(i)
        case let d as Double: try c.encode(d)
        case let s as String: try c.encode(s)
        default:              try c.encodeNil()
        }
    }
 
    var displayString: String {
        switch value {
        case let b as Bool:   return b ? "Yes" : "No"
        case let i as Int:    return "\(i)"
        case let d as Double: return String(format: "%.1f", d)
        case let s as String: return s
        default:              return "-"
        }
    }
}
