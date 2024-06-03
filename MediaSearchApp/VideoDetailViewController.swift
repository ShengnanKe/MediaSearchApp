//
//  VideoDetailViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit
import AVKit

class VideoDetailViewController: UIViewController {
    
    var mediaItem: MediaVideo?
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = mediaItem {
            videoNameLabel.text = mediaItem.url
            playVideo(from: mediaItem.videoFiles.first?.link ?? "")
        }
    }
    
    func playVideo(from url: String) {
        guard let videoURL = URL(string: url) else { return }
        
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        videoPlayerView.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        print("Bookmark button tapped")
        
        if let mediaItem = mediaItem {
            saveToBookmarks(mediaItem)
        }
    }
    
    func saveToBookmarks(_ mediaItem: MediaVideo) {
        let bookmarkModel = MediaBookmarkModel(
            name: mediaItem.url,
            url: mediaItem.videoFiles.first?.link ?? "",
            filePath: ""
        )
        if DBManager.shared.addBookmark(bookmark: bookmarkModel) {
            print("Bookmark added successfully!")
        } else {
            print("Failed to add bookmark.")
        }
    }
}
