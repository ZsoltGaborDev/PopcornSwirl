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
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        loadMovie()
        print("are \(dataSource.count) watched movies")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.latestMoviesCellNibName, bundle: nil), forCellReuseIdentifier: K.latestMoviesCellReuseId)
    }
    func loadMovie() {
        DataManager.dbShared.collection(K.FirebaseStore.watched).order(by: K.FirebaseStore.dateField).addSnapshotListener { (querySnapshot, error) in
            DataManager.shared.watchedList = []
            if let e = error {
                print("There was an issue retrieveng data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let movieId = data[K.FirebaseStore.movieBriefId] as? Int {
                            MediaService.getMovie(id: movieId) { (success, movie) in
                                if success, let movie = movie {
                                    let selectedMovie = movie
                                    DataManager.shared.watchedList.append(selectedMovie)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    self.presentNoDataAlert(title: "Oops, something happened...",
                                message: "Couldn't load any fun stuff for you:(")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func presentNoDataAlert(title: String?, message: String?) {
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
        cell.checkIfWatched(id: movieBrief.id)
        return cell
    }
    func removeFromWatched(_ cell: LatestMoviesCell) {
        if let idx = DataManager.shared.watchedList.firstIndex(where: { $0.id == cell.movieId }) {
            DataManager.shared.watchedList.remove(at: idx)
        }
        tableView.reloadData()
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

