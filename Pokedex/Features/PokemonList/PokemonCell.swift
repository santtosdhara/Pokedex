//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import UIKit

final class PokemonCell: UITableViewCell {
    static let reuseID = "PokemonCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    private func setup() {
        accessoryType = .disclosureIndicator
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(name: String, spriteURL: String?, imageLoader: ImageLoader) {
        titleLabel.text = name.capitalized
        imageLoader.loadImage(from: spriteURL, into: iconView)
    }
}
