//
//  HTTPError.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

enum HTTPError: Error, LocalizedError, Equatable {
    case invalidURL
    case transport(Error)
    case badStatus(Int)
    case deconding(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .transport(let e): return "Network error: \(e.localizedDescription)"
        case .badStatus(let code): return "Server reponded with status code \(code)"
        case .deconding: return "Failed to decode server response"
        case .noData: return "No data was returned from the server"
        }
    }
}
