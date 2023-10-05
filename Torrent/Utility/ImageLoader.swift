//
//  ImageLoader.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation
import UIKit
import Combine

// This class is responsible for loading images from a given URL.
class ImageLoader: ObservableObject {
    // The `image` property will contain the loaded UIImage once the download completes.
    @Published var image: UIImage?
    // Set to hold combine subscribers to ensure any existing subscribers are cleaned up later on.
    private var cancellables: Set<AnyCancellable> = []
    
    // This function initiates the image download from the provided URL.
    func load(url: URL) {
        // Initiating a data task with the provided URL using Combine's `dataTaskPublisher` method.
        URLSession.shared.dataTaskPublisher(for: url)
            // Mapping the received data to a UIImage.
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            // Ensuring that the UI update, when image is assigned and in the main thread.
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
            // Adding subscribers to the cancellables so they can be dealt with automatically and removed.
            .store(in: &cancellables)
    }
}
