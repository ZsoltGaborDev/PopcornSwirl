//
//  WatchedVC.swift
//  PopcornSwirl
//
//  Created by zsolt on 29/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(DataManager.shared.bookmarkedList.count)
        config()
        loadData()
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.appEnteredFromBackground),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LatestMoviesCell", bundle: nil), forCellReuseIdentifier: "latestMoviesCell")
    }
    func loadData() {
        MediaService.getMovieList(term: "movie") { (success, list) in
            if success, let list = list {
                let ready = list.sorted(by: { $0.releaseDate!.compare($1.releaseDate!) == .orderedDescending })
                
                DataManager.shared.mediaList = ready
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.presentNoDataAlert(title: "Oops, something happened...",
                message: "Couldn't load any fun stuff for you:(")
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
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, videoCell.videoURL != nil {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
    func pausePlayeVideos(){
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    func removeFromWatched(_ cell: LatestMoviesCell) {
        if let idx = DataManager.shared.watchedList.firstIndex(where: { $0.id == cell.movieId }) {
            DataManager.shared.watchedList.remove(at: idx)
        }
        tableView.reloadData()
    }
}

