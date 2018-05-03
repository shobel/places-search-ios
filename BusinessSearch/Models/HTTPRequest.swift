//
//  HTTPRequest.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/23/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON
import SwiftSpinner
import EasyToast

struct HTTPRequest{
    
    public static func makeRequest(url:String, params:[String:Any], view: UIView, callback: @escaping (JSON)->Void) {
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseSwiftyJSON { dataResponse in
            guard (dataResponse.error == nil) else {
                print("Error while fetching data: \(dataResponse.error!.localizedDescription))")
                SwiftSpinner.hide()
                var errorText = dataResponse.error!.localizedDescription
                if (errorText.contains("unacceptable")){
                    errorText = "From location required"
                }
                view.showToast(errorText, position: .bottom, popTime: 3, dismissOnTap: true)
                return
            }
            let responseJSON = JSON(dataResponse.value!)
            callback(responseJSON)
        }
    }
}
