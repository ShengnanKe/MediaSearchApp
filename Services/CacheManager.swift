//
//  CacheManager.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 200  // Set the maximum number of items the cache can hold
    }

    func image(for url: URL, completion: @escaping ((UIImage?) -> Void)) {
        if let image = cache.object(forKey: url as NSURL) {
            completion(image)
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                DispatchQueue.main.async {
                    guard let data = data,
                          let image = UIImage(data: data) else {
                        completion(nil)
                        return
                    }
                    self?.cache.setObject(image, forKey: url as NSURL)
                    completion(image)
                }
            }.resume()
        }
    }
}
