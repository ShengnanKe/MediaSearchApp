//
//  VideoSearchViewController.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit

class VideoSearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var videoSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = videoSearchBar.text, !query.isEmpty else { return }
        performSegue(withIdentifier: "showVideoSearchResults", sender: query)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoSearchResults",
           let resultsVC = segue.destination as? VideoSearchResultsViewController,
           let query = sender as? String {
            resultsVC.searchQuery = query
        }
    }
}
