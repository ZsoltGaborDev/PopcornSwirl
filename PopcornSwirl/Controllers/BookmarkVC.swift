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

    
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    var indexPath = IndexPath()
    var bookmarkedTableViewDelegate: UITableView!
    var dataSource: [MovieBrief] {
           return DataManager.shared.bookmarkedList
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.appEnteredFromBackground),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bookmarkTableView.reloadData()
        pausePlayeVideos()
    }
    func config() {
        bookmarkTableView.dataSource = self
        bookmarkTableView.delegate = self
        bookmarkTableView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "bookmarkCell")
    }
    func tableView(_ bookmarkTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ bookmarkTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.indexPath = indexPath
        let cell = bookmarkTableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkCell
        cell.bookmarkCellDelegate = self
        cell.bookmarkCellDelegate?.bookmarkedTableViewDelegate = bookmarkTableView
        let movieBrief = dataSource[indexPath.row]
        cell.configureCell(movieBrief: movieBrief)
        cell.checkIfWatched(id: movieBrief.id)
        return cell
    }
    func tableView(_ bookmarkTableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, videoCell.videoURL != nil {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }

    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: bookmarkTableView, appEnteredFromBackground: true)
    }

    func pausePlayeVideos(){
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: bookmarkTableView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    func removeFromBookmarked(_ cell: BookmarkCell) {
        if let idx = DataManager.shared.bookmarkedList.firstIndex(where: { $0.id == cell.movieId }) {
            DataManager.shared.bookmarkedList.remove(at: idx)
        }
        bookmarkTableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
       ASVideoPlayerController.sharedVideoPlayer.manuallyPausePlayeVideosFor(tableView: bookmarkTableView)
    }
}

