//
//  MediaBookmark+CoreDataProperties.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/29/24.
//
//

import Foundation
import CoreData


extension MediaBookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaBookmark> {
        return NSFetchRequest<MediaBookmark>(entityName: "MediaBookmark")
    }

    @NSManaged public var name: String?
    @NSManaged public var filePath: String?
    @NSManaged public var url: String?

}

extension MediaBookmark : Identifiable {

}
