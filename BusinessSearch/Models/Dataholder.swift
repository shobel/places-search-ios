//
//  File.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/17/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Dataholder {
    static let GoogleApiKey = "AIzaSyBY93OHlRHAuObYkHXPvYP7hrE7zWtzxKw"
    static let RequestBaseUrl = "http://hw7php.7dcpfrnk9w.us-east-2.elasticbeanstalk.com/places.php?"
    static let GoogleDirectionsUrl = "http://maps.googleapis.com/maps/api/directions/json?"
    static let YelpAppId = "bE6f8h0MwBAqadwC-5xJig"
    static let YelpAppKey = "jbAhJeUNfdBQdhFqRfO9IdDsPk9azuqloJ7__HV89wU73kQ-BHGZ12Si6Ob9zI6MGf29bpuB4f8DBGGX7QMVptZT5XG96NLNC8o6hyC4D_tQTZGkqJjsQNMqRrvPWnYx"
    
    static var cache = [String:DetailData]()
    
    static var pages = [[Business]]()
    static var favorites = [Business]()
    static var nextPageId = ""
    static var currentPage = 0
    
    static func hasNextPage() -> Bool {
        let nextPageIndex = currentPage+1
        if (pages.count > nextPageIndex){
            return true
        }
        return false
    }
    
    static func hasPrevPage() -> Bool {
        let prevPageIndex = currentPage-1
        if (prevPageIndex >= 0) {
            return true
        }
        return false
    }
    
    static func getCurrentPage() -> [Business]{
        if (pages.isEmpty){
            return []
        }
        return pages[currentPage]
    }
    
    //returns true if item was added to favorites, false if removed
    static func favoritesTapped(index: Int) -> Bool{
        let business = getCurrentPage()[index]
        if (favorites.contains(business)){
            let favIndex = favorites.index(of: business)
            favorites.remove(at: favIndex!)
            return false
        } else {
            favorites.append(getCurrentPage()[index])
            return true
        }
    }
    
    static func isFavorite(_ business:Business)->Bool{
        if (favorites.contains(business)){
            return true
        }
        return false
    }
    
    static func removeFavorite(_ business:Business){
        let index = favorites.index(of: business)
        favorites.remove(at: index!)
    }
    
    static func saveData(){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        UserDefaults.standard.set(encodedData, forKey: "favorites")
        UserDefaults.standard.synchronize()
    }
    
    static func loadData(){
        let decoded  = UserDefaults.standard.object(forKey: "favorites") as? Data
        if (decoded != nil){
            let decodedFavs = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [Business]
            favorites = decodedFavs
        }
    }
}
