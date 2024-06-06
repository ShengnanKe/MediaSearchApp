//
//  ImageSearchViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit

class ImageSearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var imageSearchBar: UISearchBar!
    var viewModel = ImageSearchViewModel() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = imageSearchBar.text, !query.isEmpty else { return }
        performSegue(withIdentifier: "showImageSearchResults", sender: query)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageSearchResults",
           let resultsVC = segue.destination as? ImageSearchResultsViewController,
           let query = sender as? String {
            resultsVC.searchQuery = query
            resultsVC.viewModel = viewModel
        }
    }

}
