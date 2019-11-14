//
//  DataManager.swift
//  PopcornSwirl
//
//  Created by zsolt on 23/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//
import UIKit
import Foundation
import Firebase

class DataManager {
    
    static let dbShared = Firestore.firestore()
    
    static func getMovies(collection: String) -> [MovieBrief]{
        var movies: [MovieBrief] = []
        DataManager.dbShared.collection(collection).order(by: K.FirebaseStore.dateField).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieveng data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let movieId = data[K.FirebaseStore.movieBriefId] as? Int {
                            MediaService.getMovie(id: movieId) { (success, movie) in
                                if success, let movie = movie {
                                    movies.append(movie)
                                }
                            }
                        }
                    }
                }
            }
        }
        return movies
    }
    
    
    static let shared = DataManager()
    private init() {
        
    }
    lazy var mediaList: [MovieBrief] = {
        var list = [MovieBrief]()

        return list
    }()
    
    lazy var bookmarkedList: [MovieBrief] = {
        var list = [MovieBrief]()
        
        return list
    }()
    
    lazy var watchedList: [MovieBrief] = {
        var list = [MovieBrief]()
        
        return list
    }()
    
    func formatDate(date: String) -> String {
        let input = date
        var output = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy"
        if let date = formatter.date(from: input) {
            output = date
        }
        return formatter.string(from: output)
    }
}
