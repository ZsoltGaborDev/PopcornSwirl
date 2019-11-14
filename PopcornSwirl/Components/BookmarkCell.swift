//
//  BookmarkCell.swift
//  PopcornSwirl
//
//  Created by zsolt on 28/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

protocol BookmarkCellDelegate {
    func removeFromBookmarked(_ cell: BookmarkCell)
    var bookmarkedTableViewDelegate: UITableView! { get set }
}

class BookmarkCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailLabel: UILabel!
    @IBOutlet weak var artworkUrl100: UIImageView!
    @IBOutlet weak var primaryGenreName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var selectWatchedBtn: UIButton!
    @IBOutlet weak var addToWatchedLabel: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var movieImageViewHeight: NSLayoutConstraint!
    
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var bookmarkCellDelegate: BookmarkCellDelegate?
    var movieId = Int()
    var videoPauseIsOn = false
    var videoControllersHidden = false
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            
            }
            videoLayer.isHidden = videoURL == nil
        }
    }    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = 5
        movieImageView.clipsToBounds = true
        movieImageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        movieImageView.layer.borderWidth = 0.5
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        movieImageView.layer.addSublayer(videoLayer)
        selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        movieImageView.addGestureRecognizer(tap)
        movieImageView.isUserInteractionEnabled = true
    }
    func configureCell(movieBrief: MovieBrief) {
        self.videoURL = movieBrief.previewUrl
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
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = movieImageView.frame
    }
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(movieImageView.frame, from: movieImageView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        if !superViewFrame.isNull {
            playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
            videoPauseIsOn = false
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
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
    
    @IBAction func onSelectWatchedBtn(_ sender: Any) {
        if checkIfWatched(id: movieId) {
            return
        } else {
            let list = DataManager.shared.mediaList
            let watchedMovie = list.filter({$0.id == self.movieId })
            
            if let watchedMovieToStore = watchedMovie.first, let user = Auth.auth().currentUser?.email {
                DataManager.dbShared.collection(K.FirebaseStore.watched).addDocument(data: [
                K.FirebaseStore.user: user,
                K.FirebaseStore.dateField: Date().timeIntervalSince1970,
                K.FirebaseStore.movieBriefId: watchedMovieToStore.id!]) { (error) in
                    if let e = error {
                        print("There were issues saving data to firestore, \(e)")
                    } else {                                    self.selectWatchedBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        self.addToWatchedLabel.text = "WATCHED"
                        print("Successfully saved data.")
                    }
                }
            }
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
    @IBAction func onPlayPauseBtn(_ sender: Any) {
        if videoPauseIsOn {
            if let url = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: url)
                videoPauseIsOn = false
                playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
            } else {
                print("videoUrl error")
            }
        } else {
            ASVideoPlayerController.sharedVideoPlayer.manuallyPausePlayeVideosFor(tableView: bookmarkCellDelegate!.bookmarkedTableViewDelegate!)
            videoPauseIsOn = true
            playPauseBtn.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    @IBAction func onMuteBtn(_ sender: Any) {
        if ASVideoPlayerController.sharedVideoPlayer.mute {
            ASVideoPlayerController.sharedVideoPlayer.mute = false
            ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: videoURL!)
            muteBtn.setImage(UIImage(systemName: "speaker.2"), for: .normal)
            if !visibleVideoHeight().isZero {
                playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
                videoPauseIsOn = false
            }
        } else {
            ASVideoPlayerController.sharedVideoPlayer.mute = true
            ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: videoURL!)

            muteBtn.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            if !visibleVideoHeight().isZero {
                playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
                videoPauseIsOn = false
            }
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if videoControllersHidden {
            playPauseBtn.isHidden = false
            muteBtn.isHidden = false
            movieTitleLabel.isHidden = false
            videoControllersHidden = false
            releaseDate.isHidden = false
        } else {
            playPauseBtn.isHidden = true
            muteBtn.isHidden = true
            movieTitleLabel.isHidden = true
            videoControllersHidden = true
            releaseDate.isHidden = true
        }
    }
}
