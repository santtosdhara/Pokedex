//
//  URLSessionProtocol.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
