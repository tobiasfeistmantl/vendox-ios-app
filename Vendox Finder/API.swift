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

struct API {
    static let PROTOCOL = "http"
    static let DOMAIN = "vendox.net"
    static let PATH = "api"
    static let VERSION = "v1"
    
    static var BASE_URL: String {
        return "\(PROTOCOL)://\(DOMAIN)/\(PATH)/\(VERSION)/"
    }
    
    static func getProducts(searchValue: String = "Seppl", location: CLLocation? = nil, responseHandler: ([Product], NSError?) -> Void) {
        var products: [Product] = []
        var API_url = API.BASE_URL + "products"
        var params: [String: AnyObject] = [
            "lat": "" as String,
            "lng": "" as String,
            "q": [
                "name_cont": searchValue
            ]
        ]
        
        if location != nil {
            params["lat"] = location!.coordinate.latitude
            params["lng"] = location!.coordinate.longitude
        }
        
        request(.GET, API_url, parameters: params).responseJSON { (_, _, jsonData, errors) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                if let data: AnyObject = jsonData {
                    for (key: String, product: JSON) in JSON(data) {
                        products.append(
                            Product(
                                name: product["name"],
                                price: product["price"],
                                description: product["description"],
                                company: product["company"],
                                image: product["picture"],
                                latitude: product["latitude"],
                                longitude: product["longitude"],
                                distanceToUser: product["distance"]
                            )
                        )
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    responseHandler(products, errors)
                }
            }
        }
    }
}