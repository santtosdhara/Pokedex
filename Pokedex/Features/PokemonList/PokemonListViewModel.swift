//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

@MainActor
final class PokemonListViewModel {
    enum State: Equatable { case idle, loading, loaded, error(String), empty }
    
    private let service: PokemonServiceProtocol
    private(set) var state: State = .idle
    private(set) var items: [NamedAPIResource] = []
    
    private let pageSize = 40
    private var offset = 0
    private var hasMore = true
    private var isLoadingMore = false
    
    init(service: PokemonServiceProtocol) {
        self.service = service
    }
    
    func loadInitial() async {
        state = .loading
        offset = 0
        do {
            let response = try await service.listPokemon(limit: pageSize, offset: offset)
            items = response.results
            hasMore = (response.next != nil)
            state = items.isEmpty ? .empty : .loaded
        } catch {
            state = .error((error as? LocalizedError)?.errorDescription ?? "An unexpected error occurred.")
        }
    }
    
    func loadMoreIfNedded(currentIndex: Int) async {
        guard hasMore, !isLoadingMore, currentIndex >= items.count - 5 else { return }
        isLoadingMore = true
        offset += pageSize
        do {
            let response = try await service.listPokemon(limit: pageSize, offset: offset)
            items.append(contentsOf: response.results)
            hasMore = (response.next != nil)
        } catch {
          
        }
        isLoadingMore = false
    }
    
}
