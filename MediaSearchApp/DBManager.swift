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
            return true
        } catch {
            print("Failed to save context: \(error)")
            print("Data unsaved!")
            return false
        }
    }
    
    // Add a MediaBookmark
    func addBookmark(bookmark: MediaBookmarkModel) -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: "MediaBookmark", in: managedContext) else {
            print("Failed to create entity description for MediaBookmark")
            return false
        }
        
        let newBookmark = NSManagedObject(entity: entity, insertInto: managedContext) as! MediaBookmark
        newBookmark.name = bookmark.name
        newBookmark.url = bookmark.url
        newBookmark.filePath = bookmark.filePath
        
        return saveData()
    }
    
    // Delete a MediaBookmark
    func deleteBookmark(bookmark: MediaBookmark) -> Bool {
        managedContext.delete(bookmark)
        return saveData()
    }
}
