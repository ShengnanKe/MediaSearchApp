//
//  VideoSearchResultsViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import CoreData
import UIKit

class VideoSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var videoTableView: UITableView!
    
    var searchQuery: String?
    let viewModel = VideoSearchResultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        videoTableView.rowHeight = 200
        
        let url = NSPersistentContainer.defaultDirectoryURL()
        print("coredata_url: ", url)
        
        if let query = searchQuery {
            viewModel.searchVideos(query: query) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.videoTableView.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        } else {
            print("Search query is nil.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videoSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let video = viewModel.videoSearchResults[indexPath.row]
        cell.videoNameLabel.text = video.user.name
        
        if let url = URL(string: video.image) {
            CacheManager.shared.image(for: url) { image in
                DispatchQueue.main.async {
                    cell.videoImageView.image = image
                }
            }
        }
        
        if indexPath.row == viewModel.videoSearchResults.count - 1 && !viewModel.isFetching {
            viewModel.currentPage += 1
            if let query = searchQuery {
                viewModel.searchVideos(query: query) { [weak self] result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self?.videoTableView.reloadData()
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo = viewModel.videoSearchResults[indexPath.row]
        performSegue(withIdentifier: "showVideoDetails", sender: selectedVideo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoDetails",
           let detailVC = segue.destination as? VideoDetailViewController,
           let video = sender as? MediaVideo {
            let viewModel = VideoDetailViewModel()
            viewModel.mediaItem = video
            detailVC.viewModel = viewModel
        }
    }
}
