//
//  BookmarkViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//
import UIKit
import CoreData
import AVFoundation

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    var bookmarks: [MediaBookmarkModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        
        bookmarkTableView.rowHeight = 200
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarksUpdated), name: NSNotification.Name("BookmarksUpdated"), object: nil)
        
        fetchBookmarks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func bookmarksUpdated() {
        fetchBookmarks()
    }
    
    func fetchBookmarks() {
        bookmarks = DBManager.shared.fetchBookmarks()
        bookmarkTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as? BookmarkTableViewCell else {
            return UITableViewCell()
        }
        
        let bookmark = bookmarks[indexPath.row]
        cell.bookmarkNameLabel.text = bookmark.name
        
        // Construct the full path dynamically
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentDirectory.appendingPathComponent(bookmark.filePath).path
        
        // Log the file path
        print("Loading image from path: \(fullPath)")
        
        if FileManager.default.fileExists(atPath: fullPath) {
            if bookmark.filePath.hasSuffix(".jpg") {
                // Handle image file
                if let image = UIImage(contentsOfFile: fullPath) {
                    cell.bookmarkImageView.image = image
                } else {
                    print("Failed to create UIImage from file at path: \(fullPath)")
                }
            } else if bookmark.filePath.hasSuffix(".mp4") {
                // Handle video file
                let thumbnail = generateThumbnail(path: fullPath)
                cell.bookmarkImageView.image = thumbnail
            }
        } else {
            print("File does not exist at path: \(fullPath)")
        }
        
        return cell
    }
    
    func generateThumbnail(path: String) -> UIImage? {
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Failed to generate thumbnail for video at path: \(path), error: \(error)")
            return nil
        }
    }
}



//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedBookmark = bookmarks[indexPath.row]
//
//        if selectedBookmark.url.contains("pexels.com/photo") {
//            performSegue(withIdentifier: "showImageDetail", sender: selectedBookmark)
//        } else if selectedBookmark.url.contains("pexels.com/video") {
//            performSegue(withIdentifier: "showVideoDetail", sender: selectedBookmark)
//        }
//    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let bookmark = sender as? MediaBookmarkModel {
//            if segue.identifier == "showImageDetail",
//               let detailVC = segue.destination as? ImageDetailViewController {
//                detailVC.mediaItem = MediaPhoto(alt: bookmark.name, url: bookmark.url)
//            } else if segue.identifier == "showVideoDetail",
//                      let detailVC = segue.destination as? VideoDetailViewController {
//                detailVC.mediaItem = MediaVideo(url: bookmark.url)
//            }
//        }
//    }
