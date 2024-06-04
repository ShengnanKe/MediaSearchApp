//
//  ImageSearchResultsViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//


import UIKit
import CoreData

class ImageSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    @IBOutlet weak var imageTableView: UITableView!
    
    var searchQuery: String?
    var isFetching = false
    var results: [MediaPhoto] = []
    // need a page # to keep track of the page and load new items through the api
    var curPageNum = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTableView.delegate = self
        imageTableView.dataSource = self
        
        imageTableView.rowHeight = 150
        
        fetchSearchResults(page: curPageNum)
        
        let url = NSPersistentContainer.defaultDirectoryURL()
        print("url: ", url)
    }
    
    func fetchSearchResults(page: Int) {
        
        let networkManager = NetworkManager.shared
        guard let query = searchQuery, !isFetching else { return }
        //        guard let query = searchQuery else { return }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        // page = 20
        let urlString = "https://api.pexels.com/v1/search?query=\(encodedQuery)&per_page=20&page=\(page)"
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        isFetching = true
        
        networkManager.request(urlString: urlString, method: .GET, headers: headers, body: nil, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetching = false
                switch result {
                case .success(let data):
                    // check if the data is being loaded coorrect
                    //print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
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
            let searchResults = try jsonDecoder.decode(MediaSearchResult.self, from: data)
            DispatchQueue.main.async {
                self.results.append(contentsOf: searchResults.photos)
                //= searchResults.photos
                //self.results.append(photos)
                self.imageTableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let photo = results[indexPath.row]
        cell.imageNameLabel.text = photo.alt
        
        if let url = URL(string: photo.src.small) { // small size
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.ImageView.image = UIImage(data: data)
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
    
    // https://www.kodeco.com/5786-uitableview-infinite-scrolling-tutorial
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPhoto = results[indexPath.row]
        performSegue(withIdentifier: "showImageDetails", sender: selectedPhoto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetails",
           let detailVC = segue.destination as? ImageDetailViewController,
           let photo = sender as? MediaPhoto {
            detailVC.mediaItem = photo
        }
    }
}

