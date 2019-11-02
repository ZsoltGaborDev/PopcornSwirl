//
//  DataManager.swift
//  PopcornSwirl
//
//  Created by zsolt on 23/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    private init() {
        
    }
    lazy var mediaList: [MovieBrief] = {
        var list = [MovieBrief]()
        
        for i in 0 ..< 10 {
            let media = MovieBrief(id: 3563563, title: "fake title \(i)", trackViewUrl: "fake link", description: "fake description", longDescription: "fake description", previewUrl: "fake URL", releaseDate: "fake date", primaryGenreName: "", artworkUrl60: "")
            list.append(media)
        }
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
