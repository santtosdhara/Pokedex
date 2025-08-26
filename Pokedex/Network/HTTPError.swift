//
//  HTTPError.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

enum HTTPError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case badStatus(Int)
    case decoding(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .transport(let e): return "Network error: \(e.localizedDescription)"
        case .badStatus(let code): return "Server reponded with status code \(code)"
        case .decoding: return "Failed to decode server response"
        case .noData: return "No data was returned from the server"
        }
    }
}

extension HTTPError: Equatable {
    static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData):
            return true

        case let (.badStatus(a), .badStatus(b)):
            return a == b

        case let (.transport(e1), .transport(e2)):
            // Compare underlying errors by domain/code so it’s stable across instances
            let n1 = e1 as NSError
            let n2 = e2 as NSError
            return n1.domain == n2.domain && n1.code == n2.code

        case (.decoding, .decoding):
            // Treat all decoding errors as equal (you can tighten this if you want)
            return true

        default:
            return false
        }
    }
}
