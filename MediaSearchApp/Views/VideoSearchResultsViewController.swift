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
    var viewModel: VideoSearchViewModel! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        videoTableView.rowHeight = 200
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let video = viewModel.searchResults[indexPath.row]
        cell.videoNameLabel.text = video.user.name
        
        // Load image for the cell
        if let url = URL(string: video.image) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        if indexPath.row == viewModel.searchResults.count - 1 && !viewModel.isFetching {
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
        let selectedVideo = viewModel.searchResults[indexPath.row]
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
