//
//  MediaServices.swift
//  PopcornSwirl
//
//  Created by zsolt on 23/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation

class MediaService {
    
    private struct API {
        private static let base = "http://itunes.apple.com/"
        private static let search = base + "search"
        private static let lookup = base + "lookup"
        
        static let searchURL = URL(string: API.search)
        static let lookupURL = URL(string: API.lookup)

        static func getMediaList() {
        }
    }
    
    private static func createRequest(url: URL, params: [String: Any]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = params.map{ "\($0)=\($1)" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        return request
    }
    
    private static func createSearchRequest(term: String) -> URLRequest {
        let params = ["term": term, "media": "movie", "entity": "movie"]
        return createRequest(url: API.searchURL!, params: params)
    }
    
    private static func createLookupRequest(id: Int) -> URLRequest {
        let params = ["id": id]
        return createRequest(url: API.lookupURL!, params: params)
    }
        
    static func getMovieList(term: String, completion: @escaping (Bool, [MovieBrief]?) -> Void) {
        
        let session = URLSession(configuration: .default)
        let request = createSearchRequest(term: term)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, error == nil {
                if let response = response as? HTTPURLResponse, response.statusCode == 200,
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = responseJSON["results"] as? [AnyObject] {
                        var list = [MovieBrief]()
                    for i in 0 ..< results.count {
                            guard let movie = results[i] as? [String: Any] else {
                                continue
                            }
                            if let id = movie["trackId"] as? Int,
                                let title = movie["trackName"] as? String,
                                let trackViewUrl = movie["trackViewUrl"] as? String,
                                let description = movie["shortDescription"] as? String,
                                let previewUrl = movie["previewUrl"] as? String,
                                let releaseDate = movie["releaseDate"] as? String,
                                let primaryGenreName = movie["primaryGenreName"] as? String,
                                let artworkUrl60 = movie["artworkUrl100"] as? String {
                                let movie = MovieBrief(id: id, title: title, trackViewUrl: trackViewUrl, description: description, previewUrl: previewUrl, releaseDate: releaseDate, primaryGenreName: primaryGenreName, artworkUrl60: artworkUrl60)
                                    list.append(movie)
                            }
                        }
                        completion(true, list)
                }
                else {
                    completion(false, nil)
                }
            }
            else {
                completion(false, nil)
            }
        }
        task.resume()
    }
    
    static func getMovie(id: Int, completion: @escaping (Bool, Movie?) -> Void) {
        let session = URLSession(configuration: .default)
        let request = createLookupRequest(id: id)
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, error == nil {
                if let response = response as? HTTPURLResponse, response.statusCode == 200,
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = responseJSON["results"] as? [AnyObject] {
                    
                    if results.count > 0,
                        let movie = results[0] as? [String: Any],
                        let id = movie["trackId"] as? Int,
                        let title = movie["trackName"] as? String,
                        let trackViewUrl = movie["trackViewUrl"] as? String,
                        let description = movie["shortDescription"] as? String,
                        let previewUrl = movie["previewUrl"] as? String,
                        let sourceUrl = movie["trackViewUrl"] as? String,
                        let releaseDate = movie["releaseDate"] as?
                            String,
                        let primaryGenreName = movie["primaryGenreName"] as? String,
                        let artworkUrl60 = movie["artworkUrl100"] as? String {
                        let media = Movie(id: id, title: title, trackViewUrl: trackViewUrl, description: description, previewUrl: previewUrl, sourceUrl: sourceUrl, releaseDate: releaseDate, primaryGenreName: primaryGenreName, artworkUrl60: artworkUrl60)
                            media.collection = movie["collectionName"] as? String
                            completion(true, media)
                        }
                        else {
                            completion(false, nil)
                        }
                    }
                    else {
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
            }
        }
        task.resume()
    }
    
    static func getImage(imageUrl: URL, completion: @escaping (Bool, Data?) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data, error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    completion(true, data)
            }
            else {
                completion(false, nil)
            }
        }
        task.resume()
    }
    
    static func getVideo(videoUrl: URL, completion: @escaping (Bool) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: videoUrl) { (data, response, error) in
            if error == nil, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            }
            else {
                completion(false)
            }
        }
        task.resume()
    }
}
