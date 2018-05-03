//
//  Review.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/20/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON

class Review{
    var icon:String
    var name:String
    var rating:Double
    var date:String
    var review:String
    var authorUrl:String
    
    var iconImage:UIImage?
    
    init(name: String, rating: Double, date: String, review: String, icon: String, authorUrl: String){
        self.name = name
        self.rating = rating
        self.date = date
        self.review = review
        self.icon = icon
        self.authorUrl = authorUrl
    }
    
    //google json response
    init(jsonObj : JSON){
        self.icon = jsonObj["profile_photo_url"].stringValue
        self.name = jsonObj["author_name"].stringValue
        self.rating = jsonObj["rating"].doubleValue
        self.date = jsonObj["time"].stringValue
        self.review = jsonObj["text"].stringValue
        self.authorUrl = jsonObj["author_url"].stringValue
    }
    
    static func sortByRating(review1:Review, review2:Review) -> Bool {
        if (review1.rating > review2.rating){
            return true
        }
        return false
    }
    
    static func sortByDate(review1:Review, review2:Review) -> Bool {
        if (Double(review1.date)! < Double(review2.date)!){
            return true
        }
        return false
    }
    
}
