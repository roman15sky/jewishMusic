//
//  TrackTableViewCell.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet var trackThumbnailImageView: UIImageView!
    @IBOutlet var trackTitleLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
