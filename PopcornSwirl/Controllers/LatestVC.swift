//
//  ViewController.swift
//  PopcornSwirl
//
//  Created by zsolt on 22/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class LatestVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataScource: [MovieBrief] {
        return DataManager.shared.mediaList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        loadData()
    }
    
    func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LatestMoviesCell", bundle: nil), forCellReuseIdentifier: "latestMoviesCell")
    }
    
    func loadData() {
        MediaService.getMovieList(term: "a+m") { (success, list) in
            if success, let list = list {
                DataManager.shared.mediaList = list
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
        return dataScource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "latestMoviesCell", for: indexPath) as! LatestMoviesCell
        let movieBrief = dataScource[indexPath.row]
        cell.populate(movieBrief: movieBrief)
        
        if let artworkData = movieBrief.artworkData,
            let artwork = UIImage(data: artworkData) {
            cell.setImage(image: artwork)
        }
        else if let imageURL = URL(string: movieBrief.artworkUrl) {
            MediaService.getImage(imageUrl: imageURL, completion: { (success, imageData) in
                if success, let imageData = imageData,
                    let artwork = UIImage(data: imageData) {
                        movieBrief.artworkData = imageData
                    DispatchQueue.main.async {
                        cell.setImage(image: artwork)
                    }
                }
            })
        }
        return cell
    }
}

