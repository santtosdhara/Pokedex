//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import Foundation

struct PokemonDetailViewModel {
    let idText: String
    let nameText: String
    let heightText: String
    let weightText: String
    let typesText: String
    let spriteURL: String?
    
    init(pokemon: Pokemon) {
        idText = "#\(pokemon.id)"
        nameText = pokemon.name.capitalized
        heightText = "Height: \(pokemon.height)"
        weightText = "Weight: \(pokemon.weight)"
        typesText = "Types: " + pokemon.types.sorted { $0.slot < $1.slot }.map { $0.type.name.capitalized }.joined(separator: ", ")
        spriteURL = pokemon.sprites.front_default
    }
}
