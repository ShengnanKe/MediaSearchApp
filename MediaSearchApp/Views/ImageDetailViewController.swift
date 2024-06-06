//
//  ImageDetailViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var viewModel: ImageDetailViewModel = ImageDetailViewModel()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = viewModel.mediaItem {
            photoNameLabel.text = mediaItem.alt
            viewModel.loadImage(from: mediaItem.src.original) { [weak self] image in
                DispatchQueue.main.async {
                    self?.photoImageView.image = image
                }
            }
        }
        
        if let bookmark = viewModel.bookmark {
            photoNameLabel.text = bookmark.name
            viewModel.loadImageBookmark(from: bookmark.filePath) { [weak self] image in
                DispatchQueue.main.async {
                    self?.photoImageView.image = image
                }
            }
        }
        
        updateBookmarkButtonAppearance()
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("Bookmark button tapped")
        viewModel.isBookmarked.toggle()
        updateBookmarkButtonAppearance()
        
        if viewModel.isBookmarked {
            viewModel.saveToBookmarks { success in
                if success {
                    print("Bookmark saved successfully.")
                } else {
                    print("Failed to save bookmark.")
                }
            }
        } else {
            print("Item unbookmarked")
        }
    }
    
    func updateBookmarkButtonAppearance() {
        DispatchQueue.main.async {
            if self.viewModel.isBookmarked {
                self.bookmarkButton.backgroundColor = .gray // when bookmarked
                self.bookmarkButton.setTitle("Bookmarked", for: .normal) //
            } else {
                self.bookmarkButton.backgroundColor = .clear // clear bg
                self.bookmarkButton.setTitle("Bookmark", for: .normal) //
            }
        }
    }
}
