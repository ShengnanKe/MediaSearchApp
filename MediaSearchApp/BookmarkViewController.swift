//
//  BookmarkViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//


import UIKit
import CoreData

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    var bookmarks: [MediaBookmarkModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        
        bookmarkTableView.rowHeight = 200
        
        fetchBookmarks()
    }
    
    func fetchBookmarks() {
        let fetchRequest: NSFetchRequest<MediaBookmark> = MediaBookmark.fetchRequest()
        
        do {
            let bookmarkEntities = try DBManager.shared.managedContext.fetch(fetchRequest)
            bookmarks = bookmarkEntities.map { entity in
                MediaBookmarkModel(
                    name: entity.name ?? "",
                    url: entity.url ?? "",
                    filePath: entity.filePath ?? ""
                )
            }
            bookmarkTableView.reloadData()
        } catch {
            print("Failed to fetch bookmarks: \(error)")
        }
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
        
        // Load image from file path
        if let image = UIImage(contentsOfFile: bookmark.filePath) {
            cell.bookmarkImageView.image = image
        }
        // bookmarkTableView.reloadData()
        return cell
    }
    
    
    func refreshBookmarks() {
        fetchBookmarks()
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
}
