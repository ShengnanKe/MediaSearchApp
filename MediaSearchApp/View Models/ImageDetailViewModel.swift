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

    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }

        CacheManager.shared.image(for: imageURL) { image in
            completion(image)
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
