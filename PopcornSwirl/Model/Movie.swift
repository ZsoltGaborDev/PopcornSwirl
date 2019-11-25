//
//  Movie.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class MovieBrief: Codable, Identifiable {
    var documentId: String? = nil
    
    var trackId: Int!
    var title: String!
    var trackViewUrl: String?
    var description: String?
    var longDescription: String?
    var previewUrl: String!
    var artworkData: Data?
    var previewData: Data?
    var releaseDate: String?
    var primaryGenreName: String?
    var artworkUrl60: String?
    var bookmarked: Bool = false
    var watched: Bool = false
    var note: String = ""
    
    init(trackId: Int,title: String, trackViewUrl: String, description: String, longDescription: String, previewUrl: String, releaseDate: String, primaryGenreName: String, artworkUrl60: String) {
        self.trackId = trackId
        self.title = title
        self.description = description
        self.longDescription = longDescription
        self.trackViewUrl = trackViewUrl
        self.previewUrl = previewUrl
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.artworkUrl60 = artworkUrl60
    }
}

protocol Identifiable {
    var documentId: String? { get set }
}
class Movie: Codable, Identifiable {
    var user: String!
    var movieId: Int!
    var documentId: String? = nil
    var comment: String?
    
    init(user: String, movieId: Int, comment: String) {
        self.user = user
        self.movieId = movieId
        self.comment = comment
        
    }
}
