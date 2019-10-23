//
//  LatestMoviesCell.swift
//  PopcornSwirl
//
//  Created by zsolt on 23/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class LatestMoviesCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(movieBrief: MovieBrief) {
        movieTitleLabel.text = movieBrief.title
        movieDetailLabel.text = movieBrief.description
    }
       
    func setImage(image: UIImage) {
        artworkImageView.image = image
    }
}
