//
//  ImageLoader.swift
//  Torrent
//
//  Created by Cube on 9/27/23.
//

import Foundation
import UIKit
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellables: Set<AnyCancellable> = []
    
    func load(url: URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
            .store(in: &cancellables)
    }
}
