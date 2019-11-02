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

protocol BookmarkCellDelegate {
    func removeFromBookmarked(_ cell: BookmarkCell)
}

class BookmarkCell: UITableViewCell {

    @IBOutlet weak var shotImageView: UIImageView!
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
    
    var bookmarkCellDelegate: BookmarkCellDelegate?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var movieId = Int()
    var videoPauseIsOn = false
    var delegate: LatestMoviesCellDelegate?
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
        shotImageView.layer.cornerRadius = 5
        shotImageView.clipsToBounds = true
        shotImageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        shotImageView.layer.borderWidth = 0.5
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        shotImageView.layer.addSublayer(videoLayer)
        //activityIndicator.color = .white
        selectionStyle = .none
    }
        
    func configureCell(movieBrief: MovieBrief) {
        movieTitleLabel.text = movieBrief.title
        movieDetailLabel.text = movieBrief.longDescription
        primaryGenreName.text = movieBrief.primaryGenreName
        releaseDate.text = DataManager.shared.formatDate(date: movieBrief.releaseDate!)
        releaseDate.layer.cornerRadius = 15
        self.videoURL = movieBrief.previewUrl
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
        videoLayer.frame = shotImageView.frame
    }
        
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(shotImageView.frame, from: shotImageView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
                return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
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
        
    @IBAction func onPlayPauseBtn(_ sender: Any) {
        if videoPauseIsOn {
            if let url = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: url)
                videoPauseIsOn = false
                playPauseBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            } else {
                print("videoUrl error")
            }
        } else {
            ASVideoPlayerController.sharedVideoPlayer.manuallyPausePlayeVideosFor(tableView: delegate!.tableViewDelegate!)
                videoPauseIsOn = true
                playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
        
    @IBAction func onMuteBtn(_ sender: Any) {
        if ASVideoPlayerController.sharedVideoPlayer.mute {
            ASVideoPlayerController.sharedVideoPlayer.mute = false
            ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: videoURL!)
            muteBtn.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        } else {
            ASVideoPlayerController.sharedVideoPlayer.mute = true
            ASVideoPlayerController.sharedVideoPlayer.playVideo(withLayer: videoLayer, url: videoURL!)

            muteBtn.setImage(UIImage(systemName: "speaker.2"), for: .normal)
        }
    }
}
