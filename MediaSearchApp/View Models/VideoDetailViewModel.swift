//
//  VideoDetailViewModel.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation
import AVKit

class VideoDetailViewModel {
    var mediaItem: MediaVideo?
    var bookmark: MediaBookmarkModel?
    var isBookmarked: Bool = false

    func loadVideo(from url: String, completion: @escaping (URL?) -> Void) {
        guard let videoURL = URL(string: url) else {
            completion(nil)
            return
        }

        CacheManager.shared.video(for: videoURL) { data in
            guard let data = data else {
                completion(nil)
                return
            }

            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            do {
                try data.write(to: fileURL)
                completion(fileURL)
            } catch {
                print("Error writing cached data to file: \(error)")
                completion(nil)
            }
        }
    }

    func loadVideoBookmark(from path: String, completion: @escaping (URL?) -> Void) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentDirectory.appendingPathComponent("videos").appendingPathComponent(path).path

        let fileURL = URL(fileURLWithPath: fullPath)
        if FileManager.default.fileExists(atPath: fullPath) {
            completion(fileURL)
        } else {
            print("Failed to load video from path: \(fullPath)")
            completion(nil)
        }
    }

    func saveToBookmarks(completion: @escaping (Bool) -> Void) {
        guard let mediaItem = mediaItem, let videoUrl = URL(string: mediaItem.videoFiles.first?.link ?? "") else {
            completion(false)
            return
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(UUID().uuidString).mp4"

        let folder = documentDirectory.appendingPathComponent("videos")
        let filePath = folder.appendingPathComponent(fileName)

        URLSession.shared.downloadTask(with: videoUrl) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                print("Failed to download video: \(String(describing: error))")
                completion(false)
                return
            }

            do {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                try fileManager.moveItem(at: localURL, to: filePath)
                print("Video saved to: \(filePath.path)")

                let bookmarkModel = MediaBookmarkModel(
                    name: mediaItem.user.name,
                    url: mediaItem.url,
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
