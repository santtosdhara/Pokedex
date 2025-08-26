//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import UIKit
final class PokemonListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let spinner = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()

    private let viewModel: PokemonListViewModel
    private let imageLoader: ImageLoader
    private var spritesCache: [String: String] = [:] // name -> spriteURL (lazy-fetched when visible)

    init(viewModel: PokemonListViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokédex"
        view.backgroundColor = .systemBackground
        setupTable()
        setupOverlay()
        Task { await loadInitial() }
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseID)
        tableView.rowHeight = 64
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    private func setupOverlay() {
        spinner.hidesWhenStopped = true
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .secondaryLabel
        errorLabel.isHidden = true
        view.addSubview(spinner)
        view.addSubview(errorLabel)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setState(_ state: PokemonListViewModel.State) {
        switch state {
        case .idle:
            spinner.stopAnimating()
            errorLabel.isHidden = true
        case .loading:
            spinner.startAnimating()
            errorLabel.isHidden = true
        case .loaded:
            spinner.stopAnimating()
            errorLabel.isHidden = true
            tableView.reloadData()
        case .empty:
            spinner.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = "No Pokémon found."
        case .error(let message):
            spinner.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = message + "\nPull to retry."
        }
    }

    private func loadInitial() async {
        await viewModel.loadInitial()
        setState(viewModel.state)
    }

    @objc private func pullToRefresh() {
        Task { [weak self] in
            await self?.viewModel.loadInitial()
            await MainActor.run {
                self?.tableView.refreshControl?.endRefreshing()
                self?.mapVisibleSpritesIfNeeded()
                self?.setState(self?.viewModel.state ?? .idle)
            }
        }
    }

    // MARK: Table DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.reuseID, for: indexPath) as? PokemonCell else { return UITableViewCell() }
        let item = viewModel.items[indexPath.row]
        let spriteURL = spritesCache[item.name]
        cell.configure(name: item.name, spriteURL: spriteURL, imageLoader: imageLoader)
        // Preload next page when approaching end
        Task { [weak self] in
            await self?.viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
            await MainActor.run {
                self?.setState(self?.viewModel.state ?? .loaded)
            }
        }
        // Lazy fetch a sprite for this row if we don't have one yet (via details endpoint)
        if spriteURL == nil {
            Task { [weak self] in
                guard let self = self, let url = URL(string: item.url) else { return }
                do {
                    let details = try await self.viewModelFetchDetails(url: url)
                    let sprite = details.sprites.front_default
                    await MainActor.run {
                        self.spritesCache[item.name] = sprite
                        if let visibleCell = tableView.cellForRow(at: indexPath) as? PokemonCell {
                            visibleCell.configure(name: item.name, spriteURL: sprite, imageLoader: self.imageLoader)
                        }
                    }
                } catch { /* ignore per-row sprite error */ }
            }
        }
        return cell
    }

    private func viewModelFetchDetails(url: URL) async throws -> Pokemon {
        try await viewModel.fetchPokemonDetails(from: url)
    }

    // MARK: Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        guard let url = URL(string: item.url) else { return }
        Task { [weak self] in
            do {
                guard let self = self else { return }
                let details = try await self.viewModelFetchDetails(url: url)
                let vm = PokemonDetailViewModel(pokemon: details)
                let vc = PokemonDetailViewController(viewModel: vm, imageLoader: self.imageLoader)
                await MainActor.run { self.navigationController?.pushViewController(vc, animated: true) }
            } catch {
                await MainActor.run { self?.presentError(error) }
            }
        }
    }

    private func presentError(_ error: Error) {
        let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func mapVisibleSpritesIfNeeded() {
        // No-op placeholder if you want to prefetch visible rows
    }
}

