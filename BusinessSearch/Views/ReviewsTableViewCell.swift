//
//  ReviewsTableViewCell.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/20/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import Cosmos

class ReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var reviewText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.settings.updateOnTouch = false
    }

}
