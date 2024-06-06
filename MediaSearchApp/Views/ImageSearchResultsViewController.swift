//
//  ImageSearchResultsViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//


import CoreData
import UIKit

class ImageSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageTableView: UITableView!
    
    var searchQuery: String?
    var viewModel: ImageSearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTableView.delegate = self
        imageTableView.dataSource = self
        
        imageTableView.rowHeight = 200
        
        let url = NSPersistentContainer.defaultDirectoryURL()
        print("coredata_url: ", url)
        
        if let query = searchQuery {
            viewModel.searchImages(query: query) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.imageTableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let photo = viewModel.searchResults[indexPath.row]
        cell.imageNameLabel.text = photo.alt
        
        if let url = URL(string: photo.src.small) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.ImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        if indexPath.row == viewModel.searchResults.count - 1 && !viewModel.isFetching {
            viewModel.currentPage += 1
            if let query = searchQuery {
                viewModel.searchImages(query: query) { [weak self] result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self?.imageTableView.reloadData()
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
        let selectedPhoto = viewModel.searchResults[indexPath.row]
        performSegue(withIdentifier: "showImageDetails", sender: selectedPhoto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetails",
           let detailVC = segue.destination as? ImageDetailViewController,
           let photo = sender as? MediaPhoto {
            let viewModel = ImageDetailViewModel()
            viewModel.mediaItem = photo
            detailVC.viewModel = viewModel
        }
    }

}
