//
//  LatestMoviesCell.swift
//  PopcornSwirl
//
//  Created by zsolt on 23/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol LatestMoviesCellDelegate {
   func pausePlayeVideos()
    var tableViewDelegate: UITableView! { get set }
}

class LatestMoviesCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    
    @IBOutlet weak var shotImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailLabel: UILabel!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var artworkUrl100: UIImageView!
    @IBOutlet weak var primaryGenreName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var addBookmarkBtn: CustomButton!
    @IBOutlet weak var selectWatchedBtn: UIButton!
    @IBOutlet weak var plusIconBookmark: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var movieId = Int()
    var delegate: LatestMoviesCellDelegate?
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(movieBrief: MovieBrief) {
        movieTitleLabel.text = movieBrief.title
        movieDetailLabel.text = movieBrief.description
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
        
        let bookmarkedMovie = DataManager.shared.bookmarkedList.filter({$0.id == self.movieId })
        if bookmarkedMovie.first?.id == movieId {
            addBookmarkBtn.isHidden = true
        } else {
            addBookmarkBtn.isHidden = false
        }
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
    
    @IBAction func onAddBookmarkBtn(_ sender: Any) {
        let list = DataManager.shared.mediaList
        let bookmarkedMovie = list.filter({$0.id == self.movieId })
        DataManager.shared.bookmarkedList.append(bookmarkedMovie.first!)
    }
    
    @IBAction func onSelectWatchedBtn(_ sender: Any) {
        let list = DataManager.shared.mediaList
        let watchedMovie = list.filter({$0.id == self.movieId })
        DataManager.shared.watchedList.append(watchedMovie.first!)
    }
    
    @IBAction func onRemoveBtn(_ sender: Any) {
    }
    
    @IBAction func onMoreBtn(_ sender: Any) {
        let list = DataManager.shared.mediaList
        let watchedMovie = list.filter({$0.id == self.movieId })
        print("\(watchedMovie.first!.trackViewUrl!)")
        guard let url = URL(string: watchedMovie.first!.trackViewUrl!) else {
          return //be safe
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func onPlayPauseBtn(_ sender: Any) {
        self.delegate?.pausePlayeVideos()
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: delegate!.tableViewDelegate, appEnteredFromBackground: true)
    }
    
    @IBAction func onMuteBtn(_ sender: Any) {
        if ASVideoPlayerController.sharedVideoPlayer.mute == true  {
            ASVideoPlayerController.sharedVideoPlayer.mute = false
        } else {
            ASVideoPlayerController.sharedVideoPlayer.mute = true
        }
    }
    
}
