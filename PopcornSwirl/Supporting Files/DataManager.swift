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
    static func store() {
       // let semaphore = DispatchSemaphore(value: 0)
        MediaService.getMovieList(term: K.searchTerm ) { (success, list) in
            if success, let list = list {
                let ready = list.sorted(by: { $0.releaseDate!.compare($1.releaseDate!) == .orderedDescending })
                print("movie from API: \(ready.count)")
                FIRFirestoreService.shared.read(from: .movies, returning: MovieBrief.self) { (existingMovies) in
                for movie in ready {
                    guard !existingMovies.contains(where: {movie.trackId == $0.trackId}) else { return }
                        FIRFirestoreService.shared.create(for: movie, in: .movies)
                    }
                }
            } else {
                print("Couldn't load any fun stuff for you:(")
            }
         //   semaphore.signal()
        }
       // semaphore.wait()
    }
    static func loadBookmarkedMovie(tableView: UITableView?) {
        DataManager.shared.bookmarkedList = DataManager.shared.mediaList.filter({$0.bookmarked == true})
        if (tableView != nil) {
            DispatchQueue.main.async {
                tableView?.reloadData()
            }
        }
    }
    static func loadWatchedMovie(tableView: UITableView?) {
        DataManager.shared.watchedList = DataManager.shared.mediaList.filter({$0.watched == true})
        if (tableView != nil) {
            DispatchQueue.main.async {
                tableView?.reloadData()
            }
        }
    }
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
    @discardableResult
    static func checkIfBookmarked(movieId: Int) -> Bool {
        let movie = DataManager.shared.bookmarkedList.filter({$0.trackId == movieId})
        if movie.first?.bookmarked == true {
            return true
        } else {
            return false
        }
    }

    @discardableResult
    static func checkIfWatched(id: Int, selectWatchedBtn: UIButton, addToWatchedLabel: UILabel ) -> Bool {
        var result = true
        let movie = DataManager.shared.mediaList.filter({$0.trackId == id})
        if movie.first?.watched == true {
            selectWatchedBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            addToWatchedLabel.text = "WATCHED"
            result = true
        } else {
            selectWatchedBtn.setImage(UIImage(systemName: "star"), for: .normal)
            addToWatchedLabel.text = "ADD TO WATCHED"
            result = false
        }
        return result
    }
    static func watchedBtnPressed (movieId: Int, watchedBtn: UIButton, watchedLabel: UILabel, tableview: UITableView) {
        if checkIfWatched(id: movieId, selectWatchedBtn: watchedBtn, addToWatchedLabel: watchedLabel) {
            return
        } else {
            let movieWatched = DataManager.shared.mediaList.filter({$0.trackId == movieId}).first
            if let movie = movieWatched {
                movie.watched = true
                FIRFirestoreService.shared.update(for: movie, in: .movies)
                DispatchQueue.main.async {
                    tableview.reloadData()
                }
            }
        }
    }
    static func bookmarkBtnPressed(movieId: Int, tableView: UITableView) {
        if  DataManager.checkIfBookmarked(movieId: movieId) {
            return
        } else {
            let bookmarkedMovie = DataManager.shared.mediaList.filter({$0.trackId == movieId}).first
            if let movie = bookmarkedMovie {
                movie.bookmarked = true
                FIRFirestoreService.shared.update(for: movie, in: .movies)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
    static func commentBtnPressed(vc: UIViewController, movieId: Int, noteLabel: UILabel) {
        let alertController = UIAlertController(title: "Note", message: "Enter your note for this movie!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            if (DataManager.shared.bookmarkedList.filter({$0.trackId == movieId}).first?.note.isEmpty)! {
                textField.placeholder = "Enter your note..."
            } else {
                textField.placeholder = DataManager.shared.bookmarkedList.filter({$0.trackId == movieId}).first?.note
            }
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    DataManager.shared.bookmarkedList.filter({$0.trackId == movieId}).first?.note = textField.text!
                    noteLabel.text = textField.text
                    noteLabel.textColor = .lightGray
                    let movie = DataManager.shared.mediaList.filter({$0.trackId == movieId}).first!
                    movie.note = textField.text!
                    FIRFirestoreService.shared.update(for: movie, in: .movies)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        vc.present(alertController, animated: true, completion: nil)
    }
}
