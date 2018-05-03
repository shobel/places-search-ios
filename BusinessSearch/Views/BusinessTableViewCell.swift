//
//  BusinessTableViewCell.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/18/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import EasyToast

protocol BusinessTableViewCellDelegate{
    func favoritesTapped(rownum:Int)
}
class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var delegate:BusinessTableViewCellDelegate?
    var rownum = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func favoriteAction(_ sender: Any) {
        self.delegate?.favoritesTapped(rownum: rownum)
        toggleFavoritesButtonIcon()
    }
    
    func toggleFavoritesButtonIcon() {
        if (favoritesButton.currentImage == UIImage(named: "favorite-empty")){
            favoritesButton.setImage(UIImage(named: "favorite-filled"), for: .normal)
        } else {
            favoritesButton.setImage(UIImage(named: "favorite-empty"), for: .normal)
        }
    }

}
