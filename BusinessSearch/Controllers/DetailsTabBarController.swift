//
//  DetailsTabBarController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/19/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON
import EasyToast
import SwiftSpinner
import YelpAPI

class DetailsTabBarController: UITabBarController {

    var business : Business!
    var json : JSON?
    var isFavorite = false
    var website = ""
    
    var photos : [UIImage] = []
    var totalPhotos = 0
    var photosDownloaded = 0
    var photosLoaded = false, reviewsLoaded = false
    
    var reviewManager = ReviewManager()
    
    enum TabType:Int {
        case InfoViewController
        case PhotosViewController
        case MapViewController
        case ReviewsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start loading")
        self.title = business?.name
        business.formattedAddress = json!["formatted_address"].stringValue
        isFavorite = false
        if (Dataholder.favorites.contains(business)){
            isFavorite = true
        }
        setFavoritesButtonIcon()
        
        //load data for data-heavy subcontrollers
        website = (json?["website"].rawString())!
        
        //try to get data from cache, otherwise load data
        if let placeDetails = Dataholder.cache[self.business.placeid] {
            self.photos = (placeDetails.getData(type: DetailData.DataType.photos) as? [UIImage])!
            self.reviewManager = (placeDetails.getData(type: DetailData.DataType.reviewManager) as? ReviewManager)!
            self.setTabsData()
            SwiftSpinner.hide()
        } else {
            loadPhotos()
            loadReviews()
        }
    }
    
    func loadPhotos(){
        loadPhotosForPlace(placeID: (business?.placeid)!)
    }
    
    func loadPhotosForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let photos = photos?.results {
                    self.totalPhotos = photos.count
                    self.photosDownloaded = 0
                    self.photos.removeAll()
                    if (self.totalPhotos == 0){
                        self.photosLoaded = true
                        self.loadCompleted()
                    }
                    for photo in photos {
                        self.loadImageForMetadata(photoMetadata: photo)
                    }
                } else {
                    self.photosLoaded = true
                    self.loadCompleted()
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                SwiftSpinner.hide()
            } else {
                self.photos.append(photo!)
                self.photosDownloaded+=1
                if (self.photosDownloaded >= self.totalPhotos){
                    self.photosLoaded = true
                    self.loadCompleted()
                }
            }
        })
    }
    
    func loadReviews(){
        //load google reviews
        if let reviews = json?["reviews"].arrayValue {
            for review in reviews {
                let reviewObj = Review(jsonObj: review)
                
                if let url = URL(string: reviewObj.icon) {
                    let data = try? Data(contentsOf: url)
                    let image = UIImage(data: data!)
                    reviewObj.iconImage = image
                }
                reviewManager.googleReviewsUnsorted.append(reviewObj)
            }
        }
        
        //load yelp reviews
        let params:[String:Any] = ["yelplat": self.business.lat, "yelplon": self.business.lng, "yelpterm": self.business.name, "yelplimit": 1]
        HTTPRequest.makeRequest(url: Dataholder.RequestBaseUrl, params: params, view: self.view) { (responseJSON) in
            SwiftSpinner.hide()
            self.parseJSON(json: responseJSON)
            self.reviewsLoaded = true
            self.loadCompleted()
        }
    }
    
    func loadCompleted(){
        if (reviewsLoaded && photosLoaded){
            print("end loading")
            
            //cache json, photos, and reviews
            let data = DetailData(json: json!, photos: photos, reviewManager: reviewManager)
            Dataholder.cache[self.business.placeid] = data
            
            setTabsData()
            
            SwiftSpinner.hide()
        }
    }
    
    func setTabsData(){
        let reviewTab = self.viewControllers![TabType.ReviewsViewController.rawValue] as! ReviewsViewController
        reviewTab.reviewList = reviewManager.googleReviewsUnsorted
        
        let photosTab = self.viewControllers![TabType.PhotosViewController.rawValue] as! PhotosViewController
        photosTab.photos = self.photos
    }
    
    func parseJSON(json:JSON){
        let reviewArray = json["reviews"].arrayValue
        for review in reviewArray{
            let reviewText = review["text"].stringValue
            let reviewTime = review["time_created"].stringValue
            let reviewerName = review["user"]["name"].stringValue
            let reviewerPic = review["user"]["image_url"].stringValue
            let reviewRating = review["rating"].doubleValue
            let reviewUrl = review["url"].stringValue
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date = dateFormatter.date(from: reviewTime) else {
                fatalError("ERROR: Date conversion failed due to mismatched format.")
            }
            
            let reviewObj = Review(name: reviewerName, rating: reviewRating, date: String(date.timeIntervalSince1970), review: reviewText, icon: reviewerPic, authorUrl: reviewUrl)
            
            if let url = URL(string: reviewerPic) {
                let data = try? Data(contentsOf: url)
                let image = UIImage(data: data!)
                reviewObj.iconImage = image
            }
            self.reviewManager.yelpReviewsUnsorted.append(reviewObj)
        }
    }

    func setFavoritesButtonIcon(){
        var favBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "favorite-empty"), style: .plain, target: self, action: #selector(favoritesTapped))
        if (isFavorite) {
            favBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "favorite-filled"), style: .plain, target: self, action: #selector(favoritesTapped))
        }
        let tweetBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "forward-arrow"), style: .plain, target: self, action: #selector(tweetTweet))
        self.navigationItem.setRightBarButtonItems([favBarButtonItem,tweetBarButtonItem], animated: true)
    }
    
    @objc func favoritesTapped() {
        var text = ""
        if Dataholder.isFavorite(business){
            Dataholder.removeFavorite(business)
            isFavorite = false
            text = business.name + " was removed from favorites"
        } else {
            Dataholder.favorites.append(business)
            isFavorite = true
            text = business.name + " was added to favorites"
        }
        setFavoritesButtonIcon()
        self.view.showToast(text, position: .bottom, popTime: 5, dismissOnTap: true)
    }
    
    @objc func tweetTweet(){
        if let text = "https://twitter.com/intent/tweet?text=Check out \(business.name) located at \(business.formattedAddress). Website: \(website). #TravelAndEntertainmentSearch".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: text)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }

}
