//
//  PullDataTableViewCell.swift
//  JewishMusic.fm
//
//  Created by Admin on 27/04/2018.
//  Copyright © 2018 JewishMusic.fm. All rights reserved.
//

import UIKit
import Foundation

class PullDataTableViewCell: UITableViewCell {

    @IBOutlet weak var progressView : UIActivityIndicatorView!
    @IBOutlet weak var progressLabel : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startStopLoading(_ isStart : Bool)
    {
        if(isStart)
        {
            progressView.isHidden = false
            progressView.startAnimating()
            progressLabel.text = "Fetching Data..."
        }
        else
        {
            progressView.isHidden = true
            progressView.stopAnimating()
            progressLabel.text = "Pull to load more Data"
        }
    }
    
}
