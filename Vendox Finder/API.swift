//
//  API.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 28/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

struct API {
    static let PROTOCOL = "http"
    static let DOMAIN = "www.vendox.net"
    static let PATH = "api"
    static let VERSION = "v1"
    
    static let keychain = Keychain(service: "net.vendox.session-token")
    
    static let RECORDS_PER_PAGE = 10
    
    static var BASE_URL: String {
        return "\(PROTOCOL)://\(DOMAIN)/\(PATH)/\(VERSION)/"
    }
    
    static var USER_TOKEN: String? {
        return keychain["token"]
    }
    
    static func getProducts(#searchValue: String, page: Int = 1, responseHandler: ([Product], NSError?) -> Void) {
        var products: [Product] = []
        var APIUrl = API.BASE_URL + "products"
        var params: [String: AnyObject] = [
            "q": [
                "name_cont": searchValue
            ],
            "page": page
        ]
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            params["without_position"] = 0
        default:
            params["without_position"] = 1
        }
        
        if let userToken = USER_TOKEN {
            params["session_token"] = userToken
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            Alamofire.request(.GET, APIUrl, parameters: params).responseJSON { (_, _, jsonData, errors) in
                if let data: AnyObject = jsonData {
                    for (key: String, product: JSON) in JSON(data) {
                        products.append(
                            Product(jsonProduct: product)
                        )
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    responseHandler(products, errors)
                }
            }
        }
    }
    
    static func setNewLocation(location: CLLocation, responseHandler: (Bool, NSHTTPURLResponse?, NSError?) -> Void) {
        var success = false
        
        if USER_TOKEN != nil {
            var APIUrl = API.BASE_URL + "users/positions"
        
            var params: JSON = [
                "position": [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                ]
            ]
            
            let mutableURLRequest = mutableURLRequestWithTokenAuthorization(url: APIUrl, httpMethod: "POST")
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = params.rawData()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                Alamofire.request(mutableURLRequest).response { (request, response, data, errors) in
                    if let response = response {
                        switch response.statusCode {
                        case 201: success = true
                        default: success = false
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        responseHandler(success, response, errors)
                    }
                }
            }
        }
    }
    
    static func getNewUserToken(responseHandler: (String?, NSHTTPURLResponse?, NSError?) -> Void) {
        var APIUrl = API.BASE_URL + "users/sessions"
        var token: String?
        
        let parameters: [String: AnyObject] = [
            "device": UIDevice.currentDevice().model
        ]
        
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            Alamofire.request(.POST, APIUrl, parameters: parameters).responseJSON { (_, response, jsonData, errors) in
                if let data: AnyObject = jsonData {
                    let userObj = JSON(data)
                    token = userObj["token"].string!
                    
                    self.keychain["token"] = token
                }
            
                dispatch_async(dispatch_get_main_queue()) {
                    responseHandler(token, response, errors)
                }
            }
        }
    }
    
    static func checkUserTokenValidity(responseHandler: (Bool, NSHTTPURLResponse?, NSError?) -> Void) {
        let APIUrl = BASE_URL + "users/session"
        let mutableURLRequest = mutableURLRequestWithTokenAuthorization(url: APIUrl)
        var validity = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            Alamofire.request(mutableURLRequest).response { (request, response, data, errors) in
                if let response = response {
                    switch response.statusCode {
                    case 200: validity = true
                    default: validity = false
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    responseHandler(validity, response, errors)
                }
            }
        }
    }
    
    static func mutableURLRequestWithTokenAuthorization(#url: String, httpMethod: String = "GET") -> NSMutableURLRequest {
        let url = NSURL(string: url)!
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        
        mutableURLRequest.HTTPMethod = httpMethod
        
        if let userToken = USER_TOKEN {
            mutableURLRequest.setValue("Token token=\(userToken)", forHTTPHeaderField: "Authorization")
        }
        
        return mutableURLRequest
    }
    
    
    
    
    
    
}