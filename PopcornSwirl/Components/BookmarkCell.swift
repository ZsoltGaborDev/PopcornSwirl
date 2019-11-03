//
//  BookmarkCell.swift
//  PopcornSwirl
//
//  Created by zsolt on 28/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GPVideoPlayer

protocol BookmarkCellDelegate {
    func removeFromBookmarked(_ cell: BookmarkCell)
    var bookmarkedTableViewDelegate: UITableView! { get set }
}

class BookmarkCell: UITableViewCell {

    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailLabel: UILabel!
    @IBOutlet weak var artworkUrl100: UIImageView!
    @IBOutlet weak var primaryGenreName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var selectWatchedBtn: UIButton!
    @IBOutlet weak var addToWatchedLabel: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    var newPlayer: GPVideoPlayer!
    
    var bookmarkCellDelegate: BookmarkCellDelegate?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var movieId = Int()
    var videoPauseIsOn = false
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
        
    func configurePlayer() {
        if let player = GPVideoPlayer.initialize(with: movieView.bounds) {
            self.movieView.addSubview(player)
            newPlayer = player
        }
    }
    
    func configureCell(movieBrief: MovieBrief) {
        configurePlayer()
        self.videoURL = movieBrief.previewUrl
        newPlayer.loadVideo(with: URL(string: videoURL!)!)
        newPlayer.pauseVideo()
        newPlayer.isToShowPlaybackControls = true
        newPlayer.isMuted = true
        movieTitleLabel.text = movieBrief.title
        movieDetailLabel.text = movieBrief.longDescription
        primaryGenreName.text = movieBrief.primaryGenreName
        releaseDate.text = DataManager.shared.formatDate(date: movieBrief.releaseDate!)
        releaseDate.layer.cornerRadius = 15
        if let imageURL = URL(string: movieBrief.artworkUrl60!) {
            MediaService.getImage(imageUrl: imageURL, completion: { (success, imageData) in
                if success, let imageData = imageData,
                    let artwork = UIImage(data: imageData) {
                        movieBrief.artworkData = imageData
                    DispatchQueue.main.async {
                        self.artworkUrl100.image = artwork
                    }
                }
            })
        }
        movieId = movieBrief.id
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
    }
        
    @IBAction func onSelectWatchedBtn(_ sender: Any) {
        if checkIfWatched(id: movieId) {
            return
        } else {
            let list = DataManager.shared.bookmarkedList
            let watchedMovie = list.filter({$0.id == self.movieId })
            DataManager.shared.watchedList.append(watchedMovie.first!)
            selectWatchedBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            addToWatchedLabel.text = "WATCHED"
        }
    }
    @discardableResult
    func checkIfWatched(id: Int) -> Bool {
        let list = DataManager.shared.watchedList
               let watchedMovie = list.filter({$0.id == id })
        if let movie = watchedMovie.first {
            if movie.id == id {
                selectWatchedBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                addToWatchedLabel.text = "WATCHED"
                return true
            } else {
                selectWatchedBtn.setImage(UIImage(systemName: "star"), for: .normal)
                addToWatchedLabel.text = "ADD TO WATCHED"
                return false
            }
        } else {
            selectWatchedBtn.setImage(UIImage(systemName: "star"), for: .normal)
            addToWatchedLabel.text = "ADD TO WATCHED"
            return false
        }
    }
        
    @IBAction func onRemoveBtn(_ sender: Any) {
        bookmarkCellDelegate?.removeFromBookmarked(self)
    }
        
    @IBAction func onMoreBtn(_ sender: Any) {
        let list = DataManager.shared.bookmarkedList
        let bookmarkedMovie = list.filter({$0.id == self.movieId })
        //print("\(bookmarkedMovie.first!.trackViewUrl!)")
        guard let url = URL(string: bookmarkedMovie.first!.trackViewUrl!) else {
            return //be safe
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
