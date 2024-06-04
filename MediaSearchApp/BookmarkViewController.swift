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
    
    // Array to hold bookmark data models
    var bookmarks: [MediaBookmarkModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.rowHeight = 200
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarksUpdated), name: NSNotification.Name("BookmarksUpdated"), object: nil)
        
        // Fetch bookmarks from Core Data
        fetchBookmarks()
    }
    
    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func bookmarksUpdated() {
        // Fetch bookmarks when notified of an update
        fetchBookmarks()
    }
    
    func fetchBookmarks() {
        // Fetch bookmarks from Core Data using DBManager
        bookmarks = DBManager.shared.fetchBookmarks()
        // Reload table view data
        bookmarkTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of bookmarks
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
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
        
        // Check if the file exists before loading
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
    
    // Function to generate thumbnail for video file
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
    
    // Enable swipe to delete functionality
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            self.deleteBookmark(at: indexPath)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func deleteBookmark(at indexPath: IndexPath) {
        guard indexPath.row < bookmarks.count else {
            print("Invalid index path")
            return
        }
        
        let bookmarkToDelete = bookmarks[indexPath.row]
        
        if DBManager.shared.deleteBookmark(filePath: bookmarkToDelete.filePath) {
            bookmarks.remove(at: indexPath.row)
            bookmarkTableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            print("Failed to delete bookmark.")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBookmark = bookmarks[indexPath.row]
        
        if selectedBookmark.url.contains("pexels.com/photos") {
            performSegue(withIdentifier: "bookmarkShowImageDetail", sender: selectedBookmark)
        } else if selectedBookmark.url.contains("pexels.com/video") {
            performSegue(withIdentifier: "bookmarkShowVideoDetail", sender: selectedBookmark)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bookmark = sender as? MediaBookmarkModel {
            if segue.identifier == "bookmarkShowImageDetail",
               let detailVC = segue.destination as? ImageDetailViewController {
                detailVC.bookmark = bookmark
            } else if segue.identifier == "bookmarkShowVideoDetail",
                      let detailVC = segue.destination as? VideoDetailViewController {
                detailVC.bookmark = bookmark
            }
        }
    }


}


