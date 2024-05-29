//
//  ImageFileDetails.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import Foundation

struct MediaSearchResult: Codable {
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }

    let page: Int
    let perPage: Int
    let photos: [MediaPhoto]
    let totalResults: Int
    let nextPage: String?
}

struct MediaPhoto: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case url
        case photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src
        case liked
        case alt
    }

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
}

struct PhotoSrc: Codable {
    enum CodingKeys: String, CodingKey {
        case original
        case large2x
        case large
        case medium
        case small
        case portrait
        case landscape
        case tiny
    }

    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
