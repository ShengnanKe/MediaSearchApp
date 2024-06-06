//
//  DBManager.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/29/24.
//

import Foundation
import CoreData
import UIKit

class DBManager: NSObject {
    // Singleton instance
    var managedContext: NSManagedObjectContext!
    
    static let shared: DBManager = {
        let instance = DBManager()
        return instance
    }()
    
    private override init() {
        super.init()
        let application = UIApplication.shared
        let appDelegate = application.delegate as? AppDelegate
        let container = appDelegate?.persistentContainer
        self.managedContext = container?.viewContext
        
    }
    
    func saveData() -> Bool {
        do {
            try managedContext.save()
            print("Data saved!")
            NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
            return true
        } catch {
            print("Failed to save context: \(error)")
            print("Data unsaved!")
            return false
        }
    }
    
    func addBookmark(bookmark: MediaBookmarkModel) -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: "MediaBookmark", in: managedContext) else {
            print("Failed to create entity description for MediaBookmark")
            return false
        }
        
        let newBookmark = NSManagedObject(entity: entity, insertInto: managedContext) as! MediaBookmark
        newBookmark.name = bookmark.name
        newBookmark.url = bookmark.url
        newBookmark.filePath = bookmark.filePath
        
        print("Adding bookmark with file path: \(bookmark.filePath)")
        
        return saveData()
    }
    
    func deleteBookmark(filePath: String) -> Bool {
        let fetchRequest: NSFetchRequest<MediaBookmark> = MediaBookmark.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "filePath == %@", filePath)
        
        do {
            let bookmarks = try managedContext.fetch(fetchRequest)
            for bookmark in bookmarks {
                managedContext.delete(bookmark)
            }
            return saveData()
        } catch {
            print("Failed to fetch bookmarks for deletion: \(error)")
            return false
        }
    }
    
    func fetchBookmarks() -> [MediaBookmarkModel] {
        let fetchRequest: NSFetchRequest<MediaBookmark> = MediaBookmark.fetchRequest()
        
        do {
            let bookmarkEntities = try managedContext.fetch(fetchRequest)
            let bookmarks = bookmarkEntities.map { entity in
                MediaBookmarkModel(
                    name: entity.name ?? "",
                    url: entity.url ?? "",
                    filePath: entity.filePath ?? ""
                )
            }
//            for bookmark in bookmarks {
//                print("Fetched bookmark with file path: \(bookmark.filePath)")
//            }
            return bookmarks
        } catch {
            print("Failed to fetch bookmarks: \(error)")
            return []
        }
    }

}
