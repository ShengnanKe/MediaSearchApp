//
//  ImageDetailViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var mediaItem: MediaPhoto?
    var isBookmarked: Bool = false
    
    // for display bookmarked items details
    var bookmark: MediaBookmarkModel?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = mediaItem {
            photoNameLabel.text = mediaItem.alt
            loadImage(from: mediaItem.src.original)
        }
        
        if let bookmark = bookmark {
            photoNameLabel.text = bookmark.name
            loadImageBookmark(from: bookmark.filePath)
        }
        
        updateBookmarkButtonAppearance()
    }
    
    func loadImage(from url: String) {
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        NetworkManager.shared.request(urlString: url, method: .GET, headers: headers, body: nil) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.photoImageView.image = UIImage(data: data)
                }
            case .failure(let error):
                print("Network error: \(error)")
            }
        }
    }
    
    func loadImageBookmark(from path: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentDirectory.appendingPathComponent(path).path
        
        if let image = UIImage(contentsOfFile: fullPath) {
            photoImageView.image = image
        } else {
            print("Failed to load image from path: \(fullPath)")
        }
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("Bookmark button tapped")
        isBookmarked.toggle()
        updateBookmarkButtonAppearance()
        
        if let mediaItem = mediaItem {
            if isBookmarked {
                saveToBookmarks(mediaItem)
            } else {
                //DBManager.deleteBookmark(mediaItem)
                print("Item unbookmarked")
            }
        }
    }
    
    func saveToBookmarks(_ mediaItem: MediaPhoto) {
        guard let image = photoImageView.image, let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(UUID().uuidString).jpg"
        
        let folder = documentDirectory.appendingPathComponent("photos")
        let filePath = folder.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath)
            print("Image saved at path: \(filePath.path)") // Log the file path
            
            let bookmarkModel = MediaBookmarkModel(
                name: mediaItem.alt,
                url: mediaItem.src.original, // original
                filePath: fileName // Save only the file name
            )
            if DBManager.shared.addBookmark(bookmark: bookmarkModel) {
                print("Bookmark added. File URL: \(filePath.path)") // Print file URL
            } else {
                print("Failed to add bookmark.")
            }
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func updateBookmarkButtonAppearance() {
        DispatchQueue.main.async {
            if self.isBookmarked {
                self.bookmarkButton.backgroundColor = .gray // when bookmarked
                self.bookmarkButton.setTitle("Bookmarked", for: .normal) //
            } else {
                self.bookmarkButton.backgroundColor = .clear // clear bg
                self.bookmarkButton.setTitle("Bookmark", for: .normal) //
            }
        }
    }
}
