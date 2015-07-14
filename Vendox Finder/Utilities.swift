//
//  Utilities.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 14/07/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation
import MapKit

func zoomToUserLocationInMapView(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
    mapView.setRegion(region, animated: true)
}