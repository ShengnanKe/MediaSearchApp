//
//  VideoSearchResultsViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit
import CoreData

class VideoSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var videoTableView: UITableView!
    
    var searchQuery: String?
    var isFetching = false
    var results: [MediaVideo] = []
    var curPageNum = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        videoTableView.rowHeight = 200
        
        fetchSearchResults(page: curPageNum)
        
        let url = NSPersistentContainer.defaultDirectoryURL()
        print("url: ", url)
    }
    
    func fetchSearchResults(page: Int) {
        let networkManager = NetworkManager.shared
        guard let query = searchQuery, !isFetching else { return }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.pexels.com/videos/search?query=\(encodedQuery)&per_page=20&page=\(page)"
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        isFetching = true
        
        networkManager.request(urlString: urlString, method: .GET, headers: headers, body: nil, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetching = false
                switch result {
                case .success(let data):
                    self.jsonDecode(data: data)
                case .failure(let error):
                    print("Network error: \(error)")
                }
            }
        })
    }
    
    func jsonDecode(data: Data) {
        let jsonDecoder = JSONDecoder()
        
        do {
            let searchResults = try jsonDecoder.decode(VideoSearchResult.self, from: data)
            DispatchQueue.main.async {
                self.results.append(contentsOf: searchResults.videos)
                self.videoTableView.reloadData()
                self.curPageNum += 1
            }
        } catch {
            print("JSON Decoding Error: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let video = results[indexPath.row]
        cell.videoNameLabel.text = video.url // no name just url
        
        if let url = URL(string: video.image) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        if indexPath.row == results.count - 1 && !isFetching {
            curPageNum += 1
            fetchSearchResults(page: curPageNum)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo = results[indexPath.row]
        performSegue(withIdentifier: "showVideoDetails", sender: selectedVideo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoDetails",
           let detailVC = segue.destination as? VideoDetailViewController,
           let video = sender as? MediaVideo {
            detailVC.mediaItem = video
        }
    }
}
