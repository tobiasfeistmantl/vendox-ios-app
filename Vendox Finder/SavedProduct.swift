//
//  SavedProduct.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 25/07/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import RealmSwift
import CoreLocation

class SavedProduct: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    
    static let realm = Realm()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var region: CLCircularRegion {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let region = CLCircularRegion(center: location.coordinate, radius: 100, identifier: "\(id)")

        region.notifyOnEntry = true
        return region
    }
    
    static func findById(id: Int) -> SavedProduct? {
        if let product = realm.objects(SavedProduct).filter("id == \(id)").first {
            return product
        }
        
        return nil
    }
    
    static func createFromProduct(product: Product) -> SavedProduct {
        let savedProduct = SavedProduct()
        
        savedProduct.id = product.id
        savedProduct.name = product.name
        savedProduct.longitude = product.location.coordinate.longitude
        savedProduct.latitude = product.location.coordinate.latitude
        
        realm.write {
            self.realm.add(savedProduct)
        }
        
        return savedProduct
    }
    
    func delete() {
        let realm = Realm()
        
        realm.write {
            realm.delete(self)
        }
    }
}
