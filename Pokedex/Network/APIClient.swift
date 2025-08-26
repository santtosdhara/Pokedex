//
//  APIClient.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

protocol APIClientProtocol {
    func get<T: Decodable>(path: String, query: [URLQueryItem]?) async throws -> T
    func getAbsolute<T: Decodable>(url: URL) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/")!
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func get<T: Decodable>(path: String, query: [URLQueryItem]? = nil) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if let query = query { components?.queryItems = query }
        guard let url = components?.url else { throw HTTPError.invalidURL }
        return try await request(url: url)
    }
    
    func getAbsolute<T>(url: URL) async throws -> T where T : Decodable {
        return try await request(url: url)
    }
    
    
    private func request<T>(url: URL) async throws -> T where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw HTTPError.noData }
            guard (200...299).contains(http.statusCode) else { throw HTTPError.badStatus(http.statusCode) }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw HTTPError.deconding(error)
            }
        } catch {
            if let httpError = error as? HTTPError { throw httpError }
            throw HTTPError.transport(error)
        }
        
    }
}
