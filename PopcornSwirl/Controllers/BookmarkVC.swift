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
           return DataManager.shared.bookmarkedList
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        loadMovie()
        adMobSetup()
        print("are \(dataSource.count) bookmarked movies")
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
        bookmarkTableView.register(UINib(nibName: K.bookmarkCellNibname, bundle: nil), forCellReuseIdentifier: K.bookmarkCellReuseId)
    }
    func adMobSetup() {
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    func loadMovie() {
        DataManager.dbShared.collection(K.FirebaseStore.bookmarked).order(by: K.FirebaseStore.dateField).addSnapshotListener { (querySnapshot, error) in
            DataManager.shared.bookmarkedList = []
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
                                    DataManager.shared.bookmarkedList.append(selectedMovie)
                                    DispatchQueue.main.async {
                                        self.bookmarkTableView.reloadData()
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
        print("received ad")
    }
    func adView(_bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
