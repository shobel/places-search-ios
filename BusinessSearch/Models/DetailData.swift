//
//  DetailData.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/24/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON

class DetailData {
    
    private var dataDict = [DataType:Any]()
    
    enum DataType {
        case json
        case photos
        case reviewManager
    }
    
    init(json: JSON, photos: [UIImage], reviewManager: ReviewManager){
        dataDict[DataType.json] = json
        dataDict[DataType.photos] = photos
        dataDict[DataType.reviewManager] = reviewManager
    }
    
    public func getData(type: DataType) -> Any {
        return dataDict[type]!
    }
    
}
