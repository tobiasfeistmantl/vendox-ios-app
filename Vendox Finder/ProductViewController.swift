//
//  ProductViewController.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 23/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Spring
import RealmSwift

class ProductViewController: UIViewController {
    var product: Product!
    var realm = Realm()
    let locationManager = CLLocationManager()

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCompanyNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productMapView: MKMapView!
    @IBOutlet weak var productDescriptionView: DesignableView!
    @IBOutlet weak var productDescriptionTitleLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productDistanceLabel: DesignableLabel!
    @IBOutlet weak var notifyMeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productNameLabel.text = product.name
        productCompanyNameLabel.text = product.company.name
        
        if let description = product.description {
            productDescriptionLabel.text = product.description
        } else {
            productDescriptionView.removeFromSuperview()
        }
        
        productMapView.addAnnotation(product.mapAnnotation)

        if let formattedPrice = product.formattedPrice() {
            productPriceLabel.text = formattedPrice
        } else {
            productPriceLabel.text = "Preis auf Nachfrage"
            productPriceLabel.textColor = UIColor.grayColor()
        }
        
        if let distance = product.distanceToUser {
            productDistanceLabel.text = "\(distance) km"
        } else {
            productDistanceLabel.removeFromSuperview()
        }
        
        zoomToUserLocationInMapView(productMapView, product.location.coordinate)
        
        if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            if product.savedProduct != nil {
                notifyMeButton.title = "Nicht mehr erinnern"
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func callCompanyButtonDidTouch(sender: UIButton) {
        let phoneNumber = product.company.phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var alert = UIAlertController(title: "Anrufen", message: "Willst du \(product.company.name) wirklich anrufen?", preferredStyle: .Alert)
        
        alert.addAction(
            UIAlertAction(title: "Ja", style: .Default) { (action: UIAlertAction!) in
                if let url = NSURL(string: "tel:\(phoneNumber)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Nein", style: .Default, handler: nil)
        )
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func writeToCompanyButtonDidTouch(sender: UIButton) {
        if let url = NSURL(string: "mailto:\(product.company.email)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func notifyMeButtonTouched(sender: UIBarButtonItem) {
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            if let savedProduct = product.savedProduct {
                removeSavedProductFromRegionMonitoring(savedProduct.region)
                notifyMeButton.title = "Erinnere mich"
            } else {
                let savedProduct = SavedProduct.createFromProduct(product)
                addSavedProductToRegionMonitoring(savedProduct)
                notifyMeButton.title = "Nicht mehr erinnern"
            }
        } else {
            let alert = UIAlertController(title: "Kein dauerhafter Zugriff auf Standort gestattet!", message: "Um dich zu informieren, wenn du in der Nähe von einem Produkt bist, müssen wir immer Zugriff auf deinen Standort haben.", preferredStyle: .ActionSheet)
            
            alert.addAction(
                UIAlertAction(title: "Einstellungen", style: .Default) { (action: UIAlertAction!) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }
            )
            
            alert.addAction(UIAlertAction(title: "Abbrechen", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
