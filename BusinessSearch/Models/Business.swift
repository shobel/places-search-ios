//
//  Business.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/17/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON

class Business : NSObject, NSCoding {
    //basic properties
    var placeid : String
    var name : String
    var address : String
    var lat : String
    var lng : String
    var icon : String
    
    //detailed properties set after instantiation
    var formattedAddress = ""
    var iconImage:UIImage?
    
    init(placeid:String, name:String, address:String, lat:String, lng:String, icon:String) {
        self.placeid = placeid
        self.name = name
        self.address = address
        self.lat = lat
        self.lng = lng
        self.icon = icon
    }

    init(jsonObj : JSON){
        self.placeid = jsonObj["place_id"].stringValue
        self.name = jsonObj["name"].stringValue
        self.address = jsonObj["vicinity"].stringValue
        self.lat = jsonObj["lat"].stringValue
        self.lng = jsonObj["lng"].stringValue
        self.icon = jsonObj["icon"].stringValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return placeid == (object as? Business)?.placeid
    }
    
    static func ==(lhs: Business, rhs: Business) -> Bool {
        if lhs.placeid == rhs.placeid {
            return true
        }
        return false
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let placeid = aDecoder.decodeObject(forKey: "placeid") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let address = aDecoder.decodeObject(forKey: "address") as! String
        let lat = aDecoder.decodeObject(forKey: "lat") as! String
        let lng = aDecoder.decodeObject(forKey: "lng") as! String
        let icon = aDecoder.decodeObject(forKey: "icon") as! String
        self.init(placeid: placeid, name: name, address: address, lat: lat, lng: lng, icon: icon)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(placeid, forKey: "placeid")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lng, forKey: "lng")
        aCoder.encode(icon, forKey: "icon")
    }
}
