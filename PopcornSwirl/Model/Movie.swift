//
//  Movie.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class MovieBrief {
    var id: Int!
    var title: String!
    var trackViewUrl: String?
    var description: String?
    var previewUrl: String!
    var artworkData: Data?
    var releaseDate: String?
    var primaryGenreName: String?
    var artworkUrl60: String?
    
    init(id: Int, title: String, trackViewUrl: String, description: String, previewUrl: String, releaseDate: String, primaryGenreName: String, artworkUrl60: String) {
        self.id = id
        self.title = title
        self.description = description
        self.trackViewUrl = trackViewUrl
        self.previewUrl = previewUrl
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.artworkUrl60 = artworkUrl60
    }
}

class Movie: MovieBrief {
    var collection: String?
    var sourceUrl: String
    
    init(id: Int, title: String, trackViewUrl: String, description: String, previewUrl: String, sourceUrl: String, releaseDate: String, primaryGenreName: String, artworkUrl60: String ) {
        self.sourceUrl = sourceUrl
        super.init(id: id, title: title, trackViewUrl: trackViewUrl, description: description, previewUrl: previewUrl, releaseDate: releaseDate, primaryGenreName: primaryGenreName, artworkUrl60: artworkUrl60)
    }
}
