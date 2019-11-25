//
//  BookmarkVC.swift
//  PopcornSwirl
//
//  Created by zsolt on 28/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//
// APP ID: ca-app-pub-1541131554989050~8522884864
// UNIT ID: ca-app-pub-1541131554989050/2845330006

import UIKit
import AVFoundation
import AVKit
import Firebase
import GoogleMobileAds


class BookmarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource, BookmarkCellDelegate {

    @IBOutlet weak var bookmarkTableView: UITableView!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var indexPath = IndexPath()
    var bookmarkedTableViewDelegate: UITableView!
    var dataSource: [MovieBrief] {
        DataManager.shared.bookmarkedList
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        adMobSetup()
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.appEnteredFromBackground),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pausePlayeVideos()
        DataManager.loadBookmarkedMovie(tableView: bookmarkTableView)
    }
    func config() {
        bookmarkTableView.dataSource = self
        bookmarkTableView.delegate = self
        bookmarkTableView.register(UINib(nibName: K.bookmarkCellNibname, bundle: nil), forCellReuseIdentifier: K.bookmarkCellReuseId)
    }
    func adMobSetup() {
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    func tableView(_ bookmarkTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ bookmarkTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.indexPath = indexPath
        let cell = bookmarkTableView.dequeueReusableCell(withIdentifier: K.bookmarkCellReuseId, for: indexPath) as! BookmarkCell
        cell.bookmarkCellDelegate = self
        cell.bookmarkCellDelegate?.bookmarkedTableViewDelegate = bookmarkTableView
        let movieBrief = dataSource[indexPath.row]
        cell.configureCell(movieBrief: movieBrief)
        if movieBrief.note.count > 0 {
            cell.noteLabel.text = movieBrief.note
        }
        DataManager.checkIfWatched(id: movieBrief.trackId, selectWatchedBtn: cell.selectWatchedBtn, addToWatchedLabel: cell.addToWatchedLabel)
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
        let movieToRemove = DataManager.shared.mediaList.filter({$0.trackId == cell.movieId}).first
        if let movie = movieToRemove {
            movie.bookmarked = false
            FIRFirestoreService.shared.update(for: movie, in: .movies)
            DataManager.loadBookmarkedMovie(tableView: bookmarkTableView)
        }
    }
    func addNote(_ cell: BookmarkCell) {
        DataManager.commentBtnPressed(vc: self, movieId: cell.movieId, noteLabel: cell.noteLabel)
        
        bookmarkTableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
       ASVideoPlayerController.sharedVideoPlayer.manuallyPausePlayeVideosFor(tableView: bookmarkTableView)
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
extension BookmarkVC: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    }
    func adView(_bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(" Error receiving add on bookmarked view \(error.localizedDescription)")
    }
}
