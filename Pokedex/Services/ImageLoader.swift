//
//  ImageLoader.swift
//  Pokedex
//
//  Created by Dhara Chavez on 8/26/25.
//

import UIKit

final class ImageLoader {
    private let cache = NSCache<NSURL, UIImage>()
    
    func loadImage(from urlString: String?, into imageView: UIImageView) {
        imageView.image = nil
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }
        Task { [weak self, weak imageView] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self?.cache.setObject(image, forKey: url as NSURL)
                    await MainActor.run { imageView?.image = image }
                }
            } catch {
                print("Ops, somethign went wrong, debug to figure it out")
            }
        }
    }
}
