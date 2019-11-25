//
//  WatchedVC.swift
//  PopcornSwirl
//
//  Created by zsolt on 29/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import Firebase

class WatchedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LatestMoviesCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    
    var tableViewDelegate: UITableView!
    var indexPath: IndexPath!
    var dataSource: [MovieBrief] {
        return DataManager.shared.watchedList
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataManager.loadWatchedMovie(tableView: tableView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.latestMoviesCellNibName, bundle: nil), forCellReuseIdentifier: K.latestMoviesCellReuseId)
    }
    func addedToBookmarkAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Got it", style: .cancel, handler: { (action) -> Void in
        })
        
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.latestMoviesCellReuseId, for: indexPath) as! LatestMoviesCell
        let movieBrief = dataSource[indexPath.row]
        cell.delegate = self
        cell.configureCell(movieBrief: movieBrief)
        cell.addBookmarkBtn.isHidden = true
        cell.movieView.isHidden = true
        cell.selectWatchedBtn.isHidden = true
        cell.plusIconBookmark.isHidden = true
        cell.movieViewHeight.constant = 0
        cell.addToWatchedLabel.isHidden = true
        return cell
    }
    func removeFromWatched(_ cell: LatestMoviesCell) {
        let movieToRemove = DataManager.shared.mediaList.filter({$0.trackId == cell.movieId}).first
        if let movie = movieToRemove {
            movie.watched = false
            FIRFirestoreService.shared.update(for: movie, in: .movies)
            DataManager.loadWatchedMovie(tableView: tableView)
        }
    }
    @IBAction func onLogOutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
