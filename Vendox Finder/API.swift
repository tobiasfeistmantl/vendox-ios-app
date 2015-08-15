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

class API {
    static let transferProtocol = "https"
    static let domain = "vendox.herokuapp.com"
    static let path = "api"
    static let version = "v2"
    
    static let recordsPerPage = 10
    
    static var URI: String {
        return "\(transferProtocol)://\(domain)/\(path)/\(version)/"
    }
    
    class Products {
        static let path = "products"
        
        static var URI: String {
            return "\(API.URI)\(path)/"
        }
        
        static func fetch(#searchValue: String, page: Int = 1, sid: Int, sessionToken: String, responseHandler: ([Product], APIError?, NSError?) -> Void) {
            var products: [Product] = []
            var apiError: APIError?
            var error: NSError?
            
            var parameters: [String: AnyObject] = [
                "q": [
                    "name_cont": searchValue
                ],
                "page": page,
                "sid": sid
            ]
            
            var headers = [
                "Authorization": "Token token=\(sessionToken)"
            ]
            
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                parameters["without_position"] = 0
            default:
                parameters["without_position"] = 1
            }
            
            Alamofire.request(.GET, URI, parameters: parameters, headers: headers).responseJSON { (request, response, data, errors) in
                error = errors
                
                if let data: AnyObject = data {
                    if response?.statusCode == 200 {
                        for (key: String, product: JSON) in JSON(data) {
                            products.append(
                                Product(
                                    jsonProduct: product
                                )
                            )
                        }
                    } else {
                        apiError = APIError(
                            JSON(data)
                        )
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    responseHandler(products, apiError, error)
                }
            }
        }
    }
    
    
    class Users {
        static let path = "users"
        static var URI: String {
            return "\(API.URI)\(path)/"
        }
        
        class Sessions {
            static let path = "sessions"
            static let singleResourcePath = "session"
            static var URI: String {
                return "\(API.Users.URI)\(path)/"
            }
            
            static var singleResourceURI: String {
                return "\(API.Users.URI)\(singleResourcePath)/"
            }
            
            static func create(device: String, responseHandler: (JSON?, APIError?, NSError?) -> Void) {
                var session: JSON?
                var apiError: APIError?
                var error: NSError?
                
                var parameters: [String: AnyObject] = [
                    "session[device]": device
                ]
                
                Alamofire.request(.POST, URI, parameters: parameters).responseJSON { (request, response, data, errors) in
                    error = errors
                    
                    if let data: AnyObject = data {
                        if response?.statusCode == 201 {
                            session = JSON(data)
                        } else {
                            apiError = APIError(
                                JSON(data)
                            )
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        responseHandler(session, apiError, error)
                    }
                }
            }
            
            static func validate(sid: Int, sessionToken: String, responseHandler: (Bool, APIError?, NSError?) -> Void) {
                var valid = false
                var apiError: APIError?
                var error: NSError?
                
                var parameters: [String: AnyObject] = [
                    "sid": sid
                ]
                
                var headers = [
                    "Authorization": "Token token=\(sessionToken)"
                ]
                
                Alamofire.request(.GET, singleResourceURI, parameters: parameters, encoding: .URL, headers: headers).responseJSON { (request, response, data, errors) in
                    error = errors
                    
                    if response?.statusCode == 200 {
                        valid = true
                    } else {
                        if let data: AnyObject = data {
                            apiError = APIError(
                                JSON(data)
                            )
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        responseHandler(valid, apiError, error)
                    }
                }
            }
        }
        
        class Positions {
            static let path = "positions"
            static var URI: String {
                return "\(API.Users.URI)\(path)/"
            }
            
            static func create(location: CLLocation, sid: Int, sessionToken: String, responseHandler: (Bool, APIError?, NSError?) -> Void) {
                var success = false
                var apiError: APIError?
                var error: NSError?
                
                var parameters: [String: AnyObject] = [
                    "sid": sid,
                    "position[latitude]": "\(location.coordinate.latitude)",
                    "position[longitude]": "\(location.coordinate.longitude)"
                ]
                
                var headers = [
                    "Authorization": "Token token=\(sessionToken)"
                ]
                
                Alamofire.request(.POST, URI, parameters: parameters, encoding: .URL, headers: headers).responseJSON { (request, response, data, errors) in
                    error = errors
                    
                    if response?.statusCode == 201 {
                        success = true
                    } else {
                        if let data: AnyObject = data {
                            apiError = APIError(
                                JSON(data)
                            )
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        responseHandler(success, apiError, error)
                    }
                }
            }
        }
    }
}













