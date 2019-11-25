//
//  ViewController.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//
// APP ID: ca-app-pub-1541131554989050~8522884864
// UNIT ID: ca-app-pub-1541131554989050/3111594327
// UNIT ID (interstitial): ca-app-pub-1541131554989050/7029408596

import UIKit
import AVFoundation
import AVKit
import Firebase
import GoogleMobileAds

class LatestVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LatestMoviesCellDelegate, GADInterstitialDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var containerActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    var tableViewDelegate: UITableView!
    var indexPath: IndexPath!
    var dataSource: [MovieBrief] {
        return DataManager.shared.mediaList
    }
    var filteredDataSource: [MovieBrief] = []
    var interstitial: GADInterstitial?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        DataManager.store()
        loadData()
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.appEnteredFromBackground),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.removeFromSuperview()
        pausePlayeVideos()
        tableView.reloadData()
    }
    func config() {
        interstitial = createAndLoadInterstitial()
        logOutBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        searchBar.delegate = self
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.lightGray
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.latestMoviesCellNibName, bundle: nil), forCellReuseIdentifier: K.latestMoviesCellReuseId)
    }
    func loadData() {
        FIRFirestoreService.shared.read(from: .movies, returning: MovieBrief.self) { (movies) in
            DataManager.shared.mediaList.removeAll()
            DataManager.shared.mediaList = movies
            self.filteredDataSource = self.dataSource
        }
    }
    func addedToBookmarkAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController,animated:true,completion:{Timer.scheduledTimer(withTimeInterval: 2, repeats:false, block: {_ in
            self.dismiss(animated: true, completion: nil)
            })
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.latestMoviesCellReuseId, for: indexPath) as! LatestMoviesCell
        cell.delegate = self
        cell.delegate?.tableViewDelegate = tableView
        cell.delegate?.indexPath = indexPath
        let movieBrief = filteredDataSource[safe: indexPath.row]
        if let movie = movieBrief {
            cell.configureCell(movieBrief: movie)
            cell.removeBtn.isHidden = true
            DataManager.checkIfWatched(id: movie.trackId, selectWatchedBtn: cell.selectWatchedBtn, addToWatchedLabel: cell.addToWatchedLabel)
        }
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
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/1033173712")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        //request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {        ad.present(fromRootViewController: self)
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    @IBAction func onLogOutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.navigationBar.isHidden = false
            navigationController?.popToRootViewController(animated: true)
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    func removeFromWatched(_ cell: LatestMoviesCell) {
        //no need here
    }
}

//MARK: search bar methods
extension LatestVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDataSource = searchText.isEmpty ? dataSource : dataSource.filter({(movies: MovieBrief) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return ((movies.primaryGenreName!.range(of: searchText, options: .caseInsensitive) != nil) || (movies.title!.range(of: searchText, options: .caseInsensitive) != nil))
        })

        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
