//
//  CacheManager.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation
import UIKit

class CacheManager {
    
    // singleton instance
    static let shared = CacheManager()
    private let imageCache = NSCache<NSURL, UIImage>()
    private let videoCache = NSCache<NSURL, NSData>()

    private init() {
        imageCache.countLimit = 100
        videoCache.countLimit = 100 
    }

    func image(for url: URL, completion: @escaping ((UIImage?) -> Void)) {
        if let image = imageCache.object(forKey: url as NSURL) {
            completion(image)
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data,
                      let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                self?.imageCache.setObject(image, forKey: url as NSURL)
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }

    func video(for url: URL, completion: @escaping (Data?) -> Void) {
        if let cachedData = videoCache.object(forKey: url as NSURL) as Data? {
            completion(cachedData)
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else {
                    completion(nil)
                    return
                }
                self?.videoCache.setObject(data as NSData, forKey: url as NSURL)
                DispatchQueue.main.async {
                    completion(data)
                }
            }.resume()
        }
    }
}

