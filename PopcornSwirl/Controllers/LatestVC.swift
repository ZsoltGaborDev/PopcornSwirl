//
//  ViewController.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//
// APP ID: ca-app-pub-1541131554989050~8522884864
// UNIT ID: ca-app-pub-1541131554989050/3111594327

import UIKit
import AVFoundation
import AVKit
import Firebase
import GoogleMobileAds

class LatestVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LatestMoviesCellDelegate, GADBannerViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var containerActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    var tableViewItems = [AnyObject]()
    var tableViewDelegate: UITableView!
    var indexPath: IndexPath!
    var dataSource: [MovieBrief] {
        return DataManager.shared.mediaList
    }
    var adsToLoad = [GADBannerView]()
    var loadStateForAds = [GADBannerView: Bool]()
    
    //Constants
    let adUnitID = "ca-app-pub-3940256099942544/2934735716"
    // A banner ad is placed in the UITableView once per `adInterval`. iPads will have a
    // larger ad interval to avoid mutliple ads being on screen at the same time.
    let adInterval = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
    // The banner ad height.
    let adViewHeight = CGFloat(100)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tableView.reloadData()
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
    }
    func config() {
        logOutBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.lightGray
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.latestMoviesCellNibName, bundle: nil), forCellReuseIdentifier: K.latestMoviesCellReuseId)
        tableView.register(UINib(nibName: "BannerAd", bundle: nil),
        forCellReuseIdentifier: "bannerAd")
        
        // Allow row height to be determined dynamically while optimizing with an estimated row height.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 135
    }
    func loadData() {
        FIRFirestoreService.shared.read(from: .movies, returning: MovieBrief.self) { (movies) in
            DataManager.shared.mediaList.removeAll()
            DataManager.shared.mediaList = movies
            print(" Movie nr. in shared media list loadData: \(DataManager.shared.mediaList.count)")
            DispatchQueue.main.async {
                self.addMenuItems()
                self.addBannerAds()
                self.preloadNextAd()
                self.tableView.reloadData()
            }
        }
    }
    func addedToBookmarkAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController,animated:true,completion:{Timer.scheduledTimer(withTimeInterval: 2, repeats:false, block: {_ in
            self.dismiss(animated: true, completion: nil)
            })
        })
    }
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
      if let tableItem = tableViewItems[indexPath.row] as? GADBannerView {
        let isAdLoaded = loadStateForAds[tableItem]
        return isAdLoaded == true ? adViewHeight : 0
      }
      return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let BannerView = tableViewItems[indexPath.row] as? GADBannerView {
          let reusableAdCell = tableView.dequeueReusableCell(withIdentifier: "bannerAd",
              for: indexPath)

          // Remove previous GADBannerView from the content view before adding a new one.
          for subview in reusableAdCell.contentView.subviews {
            subview.removeFromSuperview()
          }

          reusableAdCell.contentView.addSubview(BannerView)
          // Center GADBannerView in the table cell's content view.
          BannerView.center = reusableAdCell.contentView.center

          return reusableAdCell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.latestMoviesCellReuseId, for: indexPath) as! LatestMoviesCell
            cell.delegate = self
            cell.delegate?.tableViewDelegate = tableView
            cell.delegate?.indexPath = indexPath
            let movieBrief = dataSource[indexPath.row]
            cell.configureCell(movieBrief: movieBrief)
            cell.removeBtn.isHidden = true
            DataManager.checkIfWatched(id: movieBrief.trackId, selectWatchedBtn: cell.selectWatchedBtn, addToWatchedLabel: cell.addToWatchedLabel)
            return cell
        }
    }
    // MARK: - GADBannerView delegate methods

    func adViewDidReceiveAd(_ adView: GADBannerView) {
      // Mark banner ad as succesfully loaded.
      loadStateForAds[adView] = true
      // Load the next ad in the adsToLoad list.
      preloadNextAd()
    }
    func adView(_ adView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("Failed to receive ad on main view: \(error.localizedDescription)")
      // Load the next ad in the adsToLoad list.
      preloadNextAd()
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //let movies = DataManager.shared.mediaList.filter("primaryGenreName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "releaseDate", ascending: true)
        
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    // MARK: Adds banner ads to the tableViewItems list.

    func addBannerAds() {
      var index = adInterval
      // Ensure subview layout has been performed before accessing subview sizes.
      tableView.layoutIfNeeded()
      while index < tableViewItems.count {
        let adSize = GADAdSizeFromCGSize(
            CGSize(width: tableView.contentSize.width, height: adViewHeight))
        let adView = GADBannerView(adSize: adSize)
        adView.adUnitID = adUnitID
        adView.rootViewController = self
        adView.delegate = self

        tableViewItems.insert(adView, at: index)
        adsToLoad.append(adView)
        loadStateForAds[adView] = false

        index += adInterval
      }
    }

    /// Preload banner ads sequentially. Dequeue and load next ad from `adsToLoad` list.
    func preloadNextAd() {
      if !adsToLoad.isEmpty {
        let ad = adsToLoad.removeFirst()
        let adRequest = GADRequest()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID as! String ]
        ad.load(adRequest)
      }
    }
    func addMenuItems() {
        for item in dataSource {
            tableViewItems.append(item)
        }
    }

}

