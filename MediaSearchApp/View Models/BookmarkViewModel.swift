//
//  BookmarkViewModel.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/5/24.
//

import Foundation

class BookmarkViewModel {
    var bookmarks: [MediaBookmarkModel] = []
    
    func fetchBookmarks(completion: @escaping () -> Void) {
        bookmarks = DBManager.shared.fetchBookmarks()
        completion()
    }
    
    func deleteBookmark(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let bookmarkToDelete = bookmarks[indexPath.row]
        let success = DBManager.shared.deleteBookmark(filePath: bookmarkToDelete.filePath)
        if success {
            bookmarks.remove(at: indexPath.row)
        }
        completion(success)
    }
}

