//
//  ReviewsViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/20/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var reviewTypeControl: UISegmentedControl!
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var orderControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noReviewsView: UIView!
    
    var parentController:DetailsTabBarController!
    var reviewManager:ReviewManager!
    var reviewList = [Review]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        parentController = tabBarController as? DetailsTabBarController
        reviewManager = parentController.reviewManager
        updateReviewList()
    }
    
    func getDesiredState() -> ReviewManager.stateTuple {
        return (reviewTypeControl.selectedSegmentIndex,sortControl.selectedSegmentIndex,orderControl.selectedSegmentIndex)
    }
    
    @IBAction func reviewTypeChanged(_ sender: Any) {
        updateReviewList()
    }
    @IBAction func sortByChanged(_ sender: Any) {
        reviewList = reviewManager.getReviewList(getDesiredState())
        tableView.reloadData()
    }
    @IBAction func orderByChanged(_ sender: Any) {
        reviewList = reviewManager.getReviewList(getDesiredState())
        tableView.reloadData()
    }
    
    func updateReviewList(){
        reviewList = reviewManager.getReviewList(getDesiredState())
        if (reviewList.isEmpty){
            noReviewsView.isHidden = false
            tableView.isHidden = true
        } else {
            noReviewsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewsTableViewCell
        let review = reviewList[indexPath.row]
        cell.name.text = review.name
        cell.ratingView.rating = review.rating
        cell.reviewText.text = review.review
        
        if (review.date.contains(":")){
            cell.time.text = review.date
        } else {
            let timeInterval = TimeInterval(review.date)
            let date = Date(timeIntervalSince1970: timeInterval!)
            let dateFormatter = DateFormatter()
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            cell.time.text = strDate
        }

        if review.iconImage != nil {
            cell.profilePic.image = review.iconImage
        } else {
            cell.profilePic.image = UIImage(named: "profile-pic.png")
        }
        if (reviewTypeControl.selectedSegmentIndex == 0){
            cell.profilePic.contentMode = .scaleAspectFit
        } else {
            cell.profilePic.contentMode = .scaleToFill
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = reviewList[indexPath.row]
        if (!review.authorUrl.isEmpty){
            UIApplication.shared.open(URL(string: review.authorUrl)!, options: [:], completionHandler: nil)
        }
    }
}
