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
            let media = MovieBrief(id: 3563563, title: "fake title \(i)", artistName: "fake artist name", description: "fake description", artworkUrl: "fake URL")
            list.append(media)
        }
        return list
    }()
}
