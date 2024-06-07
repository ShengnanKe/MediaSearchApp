//
//  ImageFileDetails.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import Foundation

struct MediaSearchResult: Codable {
    let totalResults: Int
    let page: Int
    let perPage: Int
    let photos: [MediaPhoto]
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
        case photos
        case nextPage = "next_page"
    }
}

struct MediaPhoto: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let src: PhotoSrc
    let liked: Bool
    let alt: String
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

struct PhotoSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
