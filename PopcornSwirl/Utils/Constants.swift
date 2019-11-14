//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 24/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//
import UIKit

struct K {
    static let appName = "POPCORN SWIRL"
    static let searchTerm = "movie"
    static let latestMoviesCellNibName = "LatestMoviesCell"
    static let latestMoviesCellReuseId = "latestMoviesCell"
    
    static let bookmarkCellNibname = "BookmarkCell"
    static let bookmarkCellReuseId = "bookmarkCell"
    
    static let cellNibName = "MessageCell"
    static let registerSegue = "registerToLatest"
    static let loginSegue = "loginToLatest"
    static let cancel = "Cancel"
    static let emailTextFieldPlaceholder = "enter your email"
    static let passwordTextFieldPlaceholder = "password"
        
    struct Colors {
        static let buttonBlack = UIColor(red:0.12, green:0.13, blue:0.14, alpha:1.0)
        static let backgroundBlack = UIColor.black
        static let primary = UIColor.orange
        static let textWhite = UIColor(red:0.95, green:0.95, blue:0.97, alpha:1.0)
    }
    
    struct FirebaseStore {
        static let bookmarked = "bookmarkedMovies"
        static let watched = "watchedMovies"
        static let user = "user"
        static let movieBriefId = "movieBriefId"
        static let movie = "movie"
        static let note = "note"
        static let dateField = "dateField"
    }
}
