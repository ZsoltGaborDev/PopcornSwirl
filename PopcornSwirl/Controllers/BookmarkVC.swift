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
            //loadData()
            NotificationCenter.default.addObserver(self,
            selector: #selector(self.appEnteredFromBackground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkCell
        cell.bookmarkCellDelegate = self
        let movieBrief = dataSource[indexPath.row]
        cell.configureCell(movieBrief: movieBrief)
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
    override func viewDidDisappear(_ animated: Bool) {
        ASVideoPlayerController.sharedVideoPlayer.manuallyPausePlayeVideosFor(tableView: tableView)
    }
    func removeFromBookmarked(_ cell: BookmarkCell) {
        if let idx = DataManager.shared.bookmarkedList.firstIndex(where: { $0.id == cell.movieId }) {
            DataManager.shared.bookmarkedList.remove(at: idx)
        }
        tableView.reloadData()
    }
}

