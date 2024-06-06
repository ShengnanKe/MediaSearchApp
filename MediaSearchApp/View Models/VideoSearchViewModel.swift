//
//  VideoSearchViewModel.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation

class VideoSearchViewModel {
    var searchResults: [MediaVideo] = []
    var currentPage = 1
    var isFetching = false
    
    func searchVideos(query: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isFetching else { return }
        
        isFetching = true
        
        let urlString = "https://api.pexels.com/videos/search?query=\(query)&per_page=20&page=\(currentPage)"
        let headers = ["Authorization": "Ou1dFhdt9Gl2Rcu7Xfv4MzThpOZaoXYaNBpy123sCWCCJWmBqUx0m1tG"]
        
        NetworkManager.shared.request(urlString: urlString, method: .GET, headers: headers, body: nil) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let data):
                do {
                    let searchResult = try JSONDecoder().decode(VideoSearchResult.self, from: data)
                    self.searchResults.append(contentsOf: searchResult.videos)
                    self.currentPage += 1
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
