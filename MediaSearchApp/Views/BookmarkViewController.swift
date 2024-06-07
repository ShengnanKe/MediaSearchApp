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
    
    var viewModel = BookmarkViewModel()
    
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
        viewModel.fetchBookmarks { [weak self] in
            self?.bookmarkTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as? BookmarkTableViewCell else {
            return UITableViewCell()
        }
        
        let bookmark = viewModel.bookmarks[indexPath.row]
        cell.bookmarkNameLabel.text = bookmark.name
        print("Configuring cell for bookmark: \(bookmark.name)")
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Determine the appropriate folder (photos or videos) based on the file extension
        let folder: URL
        if bookmark.filePath.hasSuffix(".jpg") {
            folder = documentDirectory.appendingPathComponent("photos")
        } else if bookmark.filePath.hasSuffix(".mp4") {
            folder = documentDirectory.appendingPathComponent("videos")
        } else {
            folder = documentDirectory
        }
        
        let fullPath = folder.appendingPathComponent(bookmark.filePath).path
        print("Loading file from path: \(fullPath)")
        
        if FileManager.default.fileExists(atPath: fullPath) {
            if bookmark.filePath.hasSuffix(".jpg") {
                if let image = UIImage(contentsOfFile: fullPath) {
                    cell.bookmarkImageView.image = image
                } else {
                    print("Failed to create UIImage from file at path: \(fullPath)")
                }
            } else if bookmark.filePath.hasSuffix(".mp4") {
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
        time.value = min(time.value, 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Failed to generate thumbnail for video at path: \(path), error: \(error)")
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            self.viewModel.deleteBookmark(at: indexPath) { success in
                if success {
                    self.bookmarkTableView.performBatchUpdates({
                        self.bookmarkTableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: { _ in
                        self.viewModel.fetchBookmarks {
                            self.bookmarkTableView.reloadData()
                        }
                    })
                }
                completionHandler(success)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBookmark = viewModel.bookmarks[indexPath.row]
        
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
                let viewModel = ImageDetailViewModel()
                viewModel.bookmark = bookmark
                detailVC.viewModel = viewModel
            } else if segue.identifier == "bookmarkShowVideoDetail",
                      let detailVC = segue.destination as? VideoDetailViewController {
                let viewModel = VideoDetailViewModel()
                viewModel.bookmark = bookmark
                detailVC.viewModel = viewModel
            }
        }
    }
}
