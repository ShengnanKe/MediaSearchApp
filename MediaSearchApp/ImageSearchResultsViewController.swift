//
//  ImageSearchResultsViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//


import UIKit

class ImageSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var searchQuery: String?
    var results: [Photo] = []
    
    @IBOutlet weak var imageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTableView.delegate = self
        imageTableView.dataSource = self
        
        fetchSearchResults()
    }
    
    func fetchSearchResults() {
        
        DispatchQueue.main.async {
            self.imageTableView.reloadData()
        }
        
        let networkManager = NetworkManager.shared
        guard let query = searchQuery else { return }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.pexels.com/v1/search?query=\(encodedQuery)&per_page=20"
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        networkManager.request(urlString: urlString, method: .GET, body: nil, completion: { [weak self] result in
            switch result {
            case .success(let data):
                // check if the data is being loaded coorrect
                print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
                self?.jsonDecode(data: data)
            case .failure(let error):
                print("Network error: \(error)")
            }
        })
    }
    
    func jsonDecode(data: Data) {
        let jsonDecoder = JSONDecoder()
        
        do {
            let mediaSearchResult = try jsonDecoder.decode(ImageFileDetails.self, from: data)
            DispatchQueue.main.async {
                self.results = ImageFileDetails.photos
                self.tableView.reloadData()
            }
        } catch {
            print("JSON Decoding Error: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
        let photo = results[indexPath.row]
        cell.textLabel?.text = photo.photographer
        // Load small image for the cell
        if let url = URL(string: photo.src.small), let data = try? Data(contentsOf: url) {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPhoto = results[indexPath.row]
        performSegue(withIdentifier: "showImageDetails", sender: selectedPhoto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetails",
           let detailVC = segue.destination as? ImageDetailViewController,
           let photo = sender as? Photo {
            detailVC.mediaItem = photo
        }
    }
}

