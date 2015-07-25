//
//  Utilities.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 14/07/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import RealmSwift

let locationManager = CLLocationManager()
let realm = Realm()

func zoomToUserLocationInMapView(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
    mapView.setRegion(region, animated: true)
}

func showSimpleAlertWithTitle(title: String!, #message: String, #viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}

func addSavedProductToRegionMonitoring(savedProduct: SavedProduct) {
    locationManager.startMonitoringForRegion(savedProduct.region)
}

func removeSavedProductFromRegionMonitoring(region: CLRegion) {
    locationManager.stopMonitoringForRegion(region)
    
    let savedProduct = SavedProduct.findById(region.identifier.toInt()!)!
    
    savedProduct.delete()
}