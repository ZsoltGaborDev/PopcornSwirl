//
//  ViewController.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

class LatestVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LatestMoviesCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var tableViewDelegate: UITableView!
    var indexPath: IndexPath!
    var dataSource: [MovieBrief] {
        return DataManager.shared.mediaList
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.removeFromSuperview()
        tableView.reloadData()
        pausePlayeVideos()
        
    }
    func config() {
        mainViewTopConstraint.constant = -40
        logOutBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.lightGray
        }
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
        cell.delegate = self
        cell.delegate?.tableViewDelegate = tableView
        cell.delegate?.indexPath = indexPath
        let movieBrief = dataSource[indexPath.row]
        cell.configureCell(movieBrief: movieBrief)
        cell.removeBtn.isHidden = true
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
    func removeFromWatched(_ cell: LatestMoviesCell) {
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

//MARK: search bar methods
extension LatestVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //let movies = DataManager.shared.mediaList.filter("primaryGenreName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "releaseDate", ascending: true)
        
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
