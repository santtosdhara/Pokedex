//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import UIKit

final class PokemonDetailViewController: UIViewController {
    private let viewModel: PokemonDetailViewModel
    private let imageLoader: ImageLoader

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let heightLabel = UILabel()
    private let weightLabel = UILabel()
    private let typesLabel = UILabel()

    init(viewModel: PokemonDetailViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.nameText
        setup()
        populate()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 160).isActive = true

        [nameLabel, idLabel, heightLabel, weightLabel, typesLabel].forEach { label in
            label.font = .systemFont(ofSize: 17)
            label.textColor = .label
            label.numberOfLines = 0
        }
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)

        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, idLabel, heightLabel, weightLabel, typesLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Stretch labels to full width
        [nameLabel, idLabel, heightLabel, weightLabel, typesLabel].forEach { $0.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true }
    }

    private func populate() {
        nameLabel.text = viewModel.nameText
        idLabel.text = viewModel.idText
        heightLabel.text = viewModel.heightText
        weightLabel.text = viewModel.weightText
        typesLabel.text = viewModel.typesText
        imageLoader.loadImage(from: viewModel.spriteURL, into: imageView)
    }
}
