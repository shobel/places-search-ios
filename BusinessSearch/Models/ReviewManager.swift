//
//  File.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/21/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class ReviewManager {
    
    enum ReviewType:Int{
        case Google
        case Yelp
    }
    enum SortBy:Int{
        case Default
        case Rating
        case Date
    }
    enum Order:Int{
        case Ascending
        case Descending
    }
    
    typealias stateTuple = (type:Int, sortBy:Int, orderBy:Int)
    
    var googleReviewsUnsorted = [Review]()
    var googleReviewsSortedByRating = [Review]()
    var googleReviewsSortedByDate = [Review]()
    
    var yelpReviewsUnsorted = [Review]()
    var yelpReviewsSortedByRating = [Review]()
    var yelpReviewsSortedByDate = [Review]()
    
    func getReviewList(_ state:stateTuple) -> [Review]{
        var list = googleReviewsUnsorted
        switch state.sortBy {
        case SortBy.Rating.rawValue:
            switch state.type {
            case ReviewType.Yelp.rawValue:
                if (yelpReviewsSortedByRating.isEmpty){
                    yelpReviewsSortedByRating = yelpReviewsUnsorted.sorted(by: Review.sortByRating)
                }
                list = yelpReviewsSortedByRating
            default:
                if (googleReviewsSortedByRating.isEmpty){
                    googleReviewsSortedByRating = googleReviewsUnsorted.sorted(by: Review.sortByRating)
                }
                list = googleReviewsSortedByRating
            }
        case SortBy.Date.rawValue:
            switch state.type {
            case ReviewType.Yelp.rawValue:
                if (yelpReviewsSortedByDate.isEmpty){
                    yelpReviewsSortedByDate = yelpReviewsUnsorted.sorted(by: Review.sortByDate)
                }
                list = yelpReviewsSortedByDate
            default:
                if (googleReviewsSortedByDate.isEmpty){
                    googleReviewsSortedByDate = googleReviewsUnsorted.sorted(by: Review.sortByDate)
                }
                list = googleReviewsSortedByDate
            }
        default:
            switch state.type {
            case ReviewType.Yelp.rawValue:
                list = yelpReviewsUnsorted
            default:
                list = googleReviewsUnsorted
            }
        }
        return handleOrder(list, orderBy: state.orderBy)
    }
    
    func handleOrder(_ reviewList:[Review], orderBy:Int) -> [Review]{
        switch orderBy {
        case Order.Descending.rawValue:
            return reviewList.reversed()
        default:
            return reviewList
        }
    }
    
}
