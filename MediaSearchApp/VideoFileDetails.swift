//
//  VideoFileDetails.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 6/2/24.
//  https://www.pexels.com/api/documentation/#videos-search

import Foundation

struct VideoSearchResult: Codable {
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case videos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
    
    let page: Int
    let perPage: Int
    let videos: [MediaVideo]
    let totalResults: Int
    let nextPage: String?
}

struct MediaVideo: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case url
        case image
        case fullRes = "full_res"
        case tags
        case duration
        case user
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
    
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let fullRes: String?
    let tags: [String]
    let duration: Int
    let user: User
    let videoFiles: [VideoFile]
    let videoPictures: [VideoPicture]
}

struct User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
    }
    
    let id: Int
    let name: String
    let url: String
}

struct VideoFile: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case quality
        case fileType = "file_type"
        case width
        case height
        case fps
        case link
    }
    
    let id: Int
    let quality: String
    let fileType: String
    let width: Int
    let height: Int
    let fps: Double
    let link: String
}

struct VideoPicture: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case picture
        case nr
    }
    
    let id: Int
    let picture: String
    let nr: Int
}
