//
//  InfoViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/19/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import Cosmos

class InfoViewController: UIViewController {

    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var priceLevel: UILabel!
    @IBOutlet weak var cosmosRating: CosmosView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var googlePage: UIButton!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var phoneNumber: UITextView!
    
    var parentTabController : DetailsTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentTabController = self.tabBarController as? DetailsTabBarController
        cosmosRating.settings.updateOnTouch = false
        populate()
    }
    
    func populate(){
        let business = parentTabController.business
        let json = parentTabController.json
        
        address.text = business?.formattedAddress
        
        if let priceLevel = json?["price_level"].rawString() {
            if (priceLevel != "null") {
                priceView.isHidden = false
                setPriceLevel(price: Int(priceLevel)!)
            }
        } else {
            priceView.isHidden = true
        }
      
        phoneView.isHidden = true
        if let phoneNumberString = json?["international_phone_number"].rawString(){
            if (phoneNumberString != "null"){
                phoneNumber.text = phoneNumberString
                phoneView.isHidden = false
            }
        }
     
        websiteView.isHidden = true
        if let websiteString = json?["website"].rawString() {
            if (websiteString != "null"){
                website.setTitle(websiteString, for: .normal)
                websiteView.isHidden = false
            }
        }
        
        googleView.isHidden = true
        if let googlePageString = json?["url"].rawString() {
            if (googlePageString != "null"){
                googlePage.setTitle(googlePageString, for: .normal)
                googleView.isHidden = false
            }
        }
        
        if let rating = json?["rating"].rawString(){
            if (rating != "null"){
                cosmosRating.rating = Double(rating)!
                ratingView.isHidden = false
            }
        } else {
            ratingView.isHidden = true
        }
        
//        phoneNumber.titleLabel?.numberOfLines = 0
//        phoneNumber.titleLabel?.lineBreakMode = .byWordWrapping
        website.titleLabel?.numberOfLines = 0
        website.titleLabel?.lineBreakMode = .byWordWrapping
        googlePage.titleLabel?.numberOfLines = 0
        googlePage.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    func setPriceLevel(price: Int){
        var dollarSigns = ""
        if (price >= 0){
            for _ in 0..<price {
                dollarSigns += "$"
            }
        }
        if (price == 0){
            dollarSigns = "free"
        }
        priceLevel.text = dollarSigns
    }
    
    @IBAction func phoneNumberAction(_ sender: Any) {
        var number = phoneNumber.text?.replacingOccurrences(of: " ", with: "")
        number = number?.replacingOccurrences(of: "-", with: "")
        number = number?.replacingOccurrences(of: "+", with: "")
        guard let phoneNumber = URL(string: "tel://" + number!) else {
            guard let phoneNumber = URL(string: "sms://" + number!) else {
                return
            }
            UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
            return
        }
        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
    }
    
    @IBAction func websiteAction(_ sender: Any) {
        guard let url = URL(string: (website.titleLabel?.text)!) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func googlePageAction(_ sender: Any) {
        guard let url = URL(string: (googlePage.titleLabel?.text)!) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
