//
//  PokemonService.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

struct NamedAPIResource: Decodable, Hashable {
    let name: String
    let url: String
}

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [NamedAPIResource]
}

struct PokemonSprites: Decodable {
    let front_default: String?
}

struct PokemonTypeSlot: Decodable {
    struct PokeType: Decodable { let name: String }
    let slot: Int
    let type: PokeType
}

struct Pokemon: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: PokemonSprites
    let types: [PokemonTypeSlot]
    let base_experience: Int?
}

protocol PokemonServiceProtocol {
    func listPokemon(limit: Int, offset: Int) async throws -> PokemonListResponse
    func pokemonDetails(byID id: Int) async throws -> Pokemon
    func pokemonDetails(from absoluteURL: URL) async throws -> Pokemon
}

final class PokemonService: PokemonServiceProtocol {
    private let client: APIClientProtocol
    init(client: APIClientProtocol) { self.client = client }
    
    func listPokemon(limit: Int, offset: Int) async throws -> PokemonListResponse {
        try await client.get(path: "pokemon", query: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ])
    }
    
    func pokemonDetails(byID id: Int) async throws -> Pokemon {
        try await client.get(path: "pokemon/\(id)", query: [])
    }
    
    func pokemonDetails(from absoluteURL: URL) async throws -> Pokemon {
        try await client.getAbsolute(url: absoluteURL)
    }
}
