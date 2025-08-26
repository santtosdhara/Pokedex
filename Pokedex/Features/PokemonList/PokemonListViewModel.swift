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
        hasMore = true
        do {
            let response = try await service.listPokemon(limit: pageSize, offset: offset)
            items = response.results
            hasMore = (response.next != nil)
            state = items.isEmpty ? .empty : .loaded
        } catch {
            state = .error((error as? LocalizedError)?.errorDescription ?? "Unknown error")
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) async {
        guard hasMore, !isLoadingMore, currentIndex >= items.count - 5 else { return }
        isLoadingMore = true
        offset += pageSize
        do {
            let response = try await service.listPokemon(limit: pageSize, offset: offset)
            items.append(contentsOf: response.results)
            hasMore = (response.next != nil)
            state = .loaded
        } catch {
            // Keep old items; surface a lightweight error if desired
        }
        isLoadingMore = false
    }

    func fetchPokemonDetails(from url: URL) async throws -> Pokemon {
        try await service.pokemonDetails(from: url)
    }
}
