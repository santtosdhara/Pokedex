//
//  SceneDelegate.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        //Dependency graph
        
        let session = URLSession(configuration: .default)
        let apiClient = APIClient(session: session)
        let pokemonService = PokemonService(client: apiClient)
        let imageLoader = ImageLoader()
        
        let viewModel = PokemonListViewModel(service: pokemonService)
        let rootViewController = PokemonListViewController(viewModel: viewModel, imageLoader: imageLoader)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible( )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
     
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    
    }

    func sceneWillResignActive(_ scene: UIScene) {
       
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }

}

