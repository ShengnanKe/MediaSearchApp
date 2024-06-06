//
//  ImageDetailViewModel.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation
import UIKit

class ImageDetailViewModel {
    var mediaItem: MediaPhoto?
    var bookmark: MediaBookmarkModel?
    var isBookmarked: Bool = false
    
    let cache = NSCache<NSString, NSData>()
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedData = cache.object(forKey: url as NSString) as Data? {
            completion(UIImage(data: cachedData))
            return
        }
        
        NetworkManager.shared.request(urlString: url, method: .GET, headers: nil, body: nil) { [weak self] result in
            switch result {
            case .success(let data):
                self?.cache.setObject(data as NSData, forKey: url as NSString)
                completion(UIImage(data: data))
            case .failure(let error):
                print("Network error: \(error)")
                completion(nil)
            }
        }
    }
    
    func loadImageBookmark(from path: String, completion: @escaping (UIImage?) -> Void) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentDirectory.appendingPathComponent("photos").appendingPathComponent(path).path
        
        if let image = UIImage(contentsOfFile: fullPath) {
            completion(image)
        } else {
            print("Failed to load image from path: \(fullPath)")
            completion(nil)
        }
    }
    
    func saveToBookmarks(completion: @escaping (Bool) -> Void) {
        guard let mediaItem = mediaItem, let imageUrl = URL(string: mediaItem.src.original) else {
            completion(false)
            return
        }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(UUID().uuidString).jpg"
        
        let folder = documentDirectory.appendingPathComponent("photos")
        let filePath = folder.appendingPathComponent(fileName)
        
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image: \(String(describing: error))")
                completion(false)
                return
            }
            
            do {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: filePath)
                print("Image saved at path: \(filePath.path)")
                
                let bookmarkModel = MediaBookmarkModel(
                    name: mediaItem.alt,
                    url: mediaItem.src.original,
                    filePath: fileName // Save only the file name
                )
                DispatchQueue.main.async {
                    if DBManager.shared.addBookmark(bookmark: bookmarkModel) {
                        print("Bookmark added. File URL: \(filePath.path)") // Print file URL
                        completion(true)
                    } else {
                        print("Failed to add bookmark.")
                        completion(false)
                    }
                }
            } catch {
                print("Error saving bookmark: \(error)")
                completion(false)
            }
        }.resume()
    }
}
