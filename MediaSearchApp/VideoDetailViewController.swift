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
    var isBookmarked: Bool = false
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mediaItem = mediaItem {
            videoNameLabel.text = mediaItem.user.name
            loadVideo(from: mediaItem.videoFiles.first?.link ?? "")
        }
        
        updateBookmarkButtonAppearance()
    }
    
    func loadVideo(from url: String) {
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        NetworkManager.shared.request(urlString: url, method: .GET, headers: headers, body: nil) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.playVideo(from: url)
                }
            case .failure(let error):
                print("Network error: \(error)")
            }
        }
    }
    
    func playVideo(from url: String) {
        guard let videoURL = URL(string: url) else { return }
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoPlayerView.bounds
        videoPlayerView.layer.addSublayer(playerLayer!)
        player?.play()
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
    
    func saveToBookmarks(_ mediaItem: MediaVideo) {
        guard let imageUrl = URL(string: mediaItem.image) else {
            print("Invalid image URL")
            return
        }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        
        // Load image data asynchronously
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let imageData = data, error == nil else {
                print("Failed to load image data: \(String(describing: error))")
                return
            }
            
            do {
                try imageData.write(to: filePath)
                
                let bookmarkModel = MediaBookmarkModel(
                    name: mediaItem.user.name,
                    url: mediaItem.url,
                    filePath: filePath.path
                )
                DispatchQueue.main.async {
                    if DBManager.shared.addBookmark(bookmark: bookmarkModel) {
                        print("Bookmark added.")
                        //print("Bookmark added. File URL: \(filePath)") // Print file URL
                    } else {
                        print("Failed to add bookmark.")
                    }
                }
            } catch {
                print("Error saving bookmark: \(error)")
            }
        }.resume()
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
