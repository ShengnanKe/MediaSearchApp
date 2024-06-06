//
//  BookmarkViewModel.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation

class BookmarkViewModel {
    var bookmarks: [MediaBookmarkModel] = []
    
    func fetchBookmarks(completion: @escaping (Result<Void, Error>) -> Void) {
        bookmarks = DBManager.shared.fetchBookmarks()
        completion(.success(()))
    }
    
    func deleteBookmark(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard index < bookmarks.count else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Index out of range"])))
            return
        }
        
        let bookmarkToDelete = bookmarks[index]
        if DBManager.shared.deleteBookmark(filePath: bookmarkToDelete.filePath) {
            bookmarks.remove(at: index)
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete bookmark"])))
        }
    }
}
