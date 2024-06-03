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
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = mediaItem {
            photoNameLabel.text = mediaItem.alt
            loadImage(from: mediaItem.src.original)
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
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("Bookmark button tapped")
        isBookmarked.toggle()
        updateBookmarkButtonAppearance()
        
        if let mediaItem = mediaItem {
            if isBookmarked {
                saveToBookmarks(mediaItem)
            } else {
                // Optionally, handle unbookmarking logic here
                print("Item unbookmarked")
            }
        }
    }
    
    func saveToBookmarks(_ mediaItem: MediaPhoto) {
        guard let image = photoImageView.image, let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        
        do {
            try imageData.write(to: filePath)
            
            let bookmarkModel = MediaBookmarkModel(
                name: mediaItem.alt,
                url: mediaItem.src.original,
                filePath: filePath.path
            )
            if DBManager.shared.addBookmark(bookmark: bookmarkModel) {
                print("Bookmark added.")
                //print("Bookmark added. File URL: \(filePath)") // Print file URL
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
