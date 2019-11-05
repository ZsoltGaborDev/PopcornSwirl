//
//  WatchedVC.swift
//  PopcornSwirl
//
//  Created by zsolt on 29/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class WatchedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LatestMoviesCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        print(DataManager.shared.bookmarkedList.count)
        config()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LatestMoviesCell", bundle: nil), forCellReuseIdentifier: "latestMoviesCell")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "latestMoviesCell", for: indexPath) as! LatestMoviesCell
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
}

