//
//  VideoDetailViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit
import AVKit

class VideoDetailViewController: UIViewController {
    
    var viewModel: VideoDetailViewModel = VideoDetailViewModel()
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    private var playerViewController: AVPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = viewModel.mediaItem {
            videoNameLabel.text = mediaItem.user.name
            viewModel.loadVideo(from: mediaItem.videoFiles.first?.link ?? "") { [weak self] url in
                DispatchQueue.main.async {
                    if let url = url {
                        self?.playVideo(from: url)
                    }
                }
            }
        }
        
        if let bookmark = viewModel.bookmark {
            videoNameLabel.text = bookmark.name
            viewModel.loadVideoBookmark(from: bookmark.filePath) { [weak self] url in
                DispatchQueue.main.async {
                    if let url = url {
                        self?.playVideo(from: url)
                    }
                }
            }
        }
        
        updateBookmarkButtonAppearance()
    }
    
    func playVideo(from url: URL) {
        playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerViewController?.player = player
        addChild(playerViewController!)
        videoPlayerView.addSubview(playerViewController!.view)
        playerViewController?.view.frame = videoPlayerView.bounds
        player.play()
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
