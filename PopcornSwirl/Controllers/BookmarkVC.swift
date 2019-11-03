//
//  BookmarkVC.swift
//  PopcornSwirl
//
//  Created by zsolt on 28/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class BookmarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource, BookmarkCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var indexPath = IndexPath()
    var bookmarkedTableViewDelegate: UITableView!
    var dataSource: [MovieBrief] {
           return DataManager.shared.bookmarkedList
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    override func viewDidLoad() {
            super.viewDidLoad()
            print(DataManager.shared.bookmarkedList.count)
            config()
    }
    
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "bookmarkCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.indexPath = indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkCell
        cell.bookmarkCellDelegate = self
        cell.bookmarkCellDelegate?.bookmarkedTableViewDelegate = tableView
        let movieBrief = dataSource[indexPath.row]
        cell.configureCell(movieBrief: movieBrief)
        cell.checkIfWatched(id: movieBrief.id)
        return cell
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    func removeFromBookmarked(_ cell: BookmarkCell) {
        if let idx = DataManager.shared.bookmarkedList.firstIndex(where: { $0.id == cell.movieId }) {
            DataManager.shared.bookmarkedList.remove(at: idx)
        }
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        if DataManager.shared.bookmarkedList.count > 0 {
            let cell = bookmarkedTableViewDelegate.cellForRow(at: indexPath) as! BookmarkCell
            cell.newPlayer.pauseVideo()
        }
    }
}

