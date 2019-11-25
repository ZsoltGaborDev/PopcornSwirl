//
//  WatchedCell.swift
//  PopcornSwirl
//
//  Created by zsolt on 19/11/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase

protocol WatchedCellDelegate {
    var tableViewDelegate: UITableView! { get set }
    var indexPath: IndexPath! {get set}
    func removeFromWatched(_ cell: WatchedCell)
}

class WatchedCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailLabel: UILabel!
    @IBOutlet weak var artworkUrl100: UIImageView!
    @IBOutlet weak var primaryGenreName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var movieId = Int()
    var videoPauseIsOn = false
    var watchedCelldelegate: WatchedCellDelegate?
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
        selectionStyle = .none
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
        movieId = movieBrief.trackId
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    @IBAction func onRemoveBtn(_ sender: Any) {
        watchedCelldelegate?.removeFromWatched(self)
    }
    @IBAction func onMoreBtn(_ sender: Any) {
        MediaService.moreBtnPressed(movieId: movieId)
    }
}
