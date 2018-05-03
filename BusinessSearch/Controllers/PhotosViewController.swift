//
//  PhotosViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/19/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftSpinner

class PhotosViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPhotosView: UIView!
    var photos : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if (photos.isEmpty){
            tableView.isHidden = true
            noPhotosView.isHidden = false
        } else {
            tableView.isHidden = false
            noPhotosView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        let photo = photos[indexPath.row]
        for view in cell.contentView.subviews {
            if (view.restorationIdentifier == "photoView") {
                let x = view as! UIImageView
                x.image = photo
            }
        }
        return cell
    }

}
