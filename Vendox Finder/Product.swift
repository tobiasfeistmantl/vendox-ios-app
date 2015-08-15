//
//  Product.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 23/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

struct Product {
    var id: Int
    var name: String
    var priceInCent: Int?
    var price: Double?
    var description: String?
    var company: Company
    var image: UIImage
    var location: CLLocation
    var distanceToUser: Double?
    
    init(id: Int, name: String, price: Double?, description: String?, company: Company, image: UIImage, location: CLLocation, distanceToUser: Double?) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.company = company
        self.image = image
        self.location = location
        self.distanceToUser = distanceToUser
    }
    
    /*** For API data ***/
    init(id: JSON, name: JSON, priceInCent: JSON, description: JSON, company: JSON, image: JSON, latitude: JSON, longitude: JSON, distanceToUser: JSON) {
        self.id = id.int!
        self.name = name.string!
        self.priceInCent = priceInCent.int
        
        if let priceInCent = self.priceInCent {
            self.price = Double(priceInCent) / 100
        }
        
        self.description = description.string
        
        self.company = Company(
            id: company["id"].int!,
            name: company["name"].string!,
            street: company["street"].string!,
            zipCode: company["zip_code"].string!,
            locality: company["locality"].string!,
            phoneNumber: company["phone_number"].string!,
            email: company["email"].string!
        )
        
        self.image = UIImage(
            data: NSData(
                contentsOfURL: NSURL(
                    string: image["url"].string!
                )!
            )!
        )!
        
        self.location = CLLocation(
            latitude: latitude.double!,
            longitude: longitude.double!
        )
        
        self.distanceToUser = distanceToUser.double
    }
    
    init(jsonProduct product: JSON) {
        self.init(
            id: product["id"],
            name: product["name"],
            priceInCent: product["price_in_cent"],
            description: product["description"],
            company: product["company"],
            image: product["picture"],
            latitude: product["latitude"],
            longitude: product["longitude"],
            distanceToUser: product["distance"]
        )
    }
    /*** For API data ***/
    
    func formattedPrice(currencyCode: String = "EUR") -> String? {
        if let price = self.price {
            let formatter = NSNumberFormatter()
        
            formatter.numberStyle = .CurrencyStyle
            formatter.currencyCode = currencyCode
            
            return formatter.stringFromNumber(price)
        } else {
            return nil
        }
    }
    
    var mapAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location.coordinate
        annotation.title = company.name
        annotation.subtitle = company.fullAddress
        
        return annotation
    }
    
    var savedProduct: SavedProduct? {
        return SavedProduct.findById(id)
    }
}