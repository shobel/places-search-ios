//
//  FavoritesTableViewCell.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/18/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    var rownum = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
