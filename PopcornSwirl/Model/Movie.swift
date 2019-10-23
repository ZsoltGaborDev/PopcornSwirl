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
    var artistName: String?
    var description: String?
    var artworkUrl: String!
    var artworkData: Data?
    
    init(id: Int, title: String, artistName: String, description: String, artworkUrl: String) {
        self.id = id
        self.title = title
        self.description = description
        self.artistName = artistName
        self.artworkUrl = artworkUrl
    }
}

class Movie: MovieBrief {
    var collection: String?
    var sourceUrl: String
    
    init(id: Int, title: String, artistName: String, description: String, artworkUrl: String, sourceUrl: String) {
        self.sourceUrl = sourceUrl
        super.init(id: id, title: title, artistName: artistName, description: description, artworkUrl: artworkUrl)
    }
}
