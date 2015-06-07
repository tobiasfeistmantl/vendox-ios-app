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

class ProductViewController: UIViewController {
    var product: Product!

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCompanyNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescriptionTitleLabel: UILabel!
    @IBOutlet weak var productMapView: MKMapView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productDistanceLabel: DesignableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productNameLabel.text = product.name
        productCompanyNameLabel.text = product.company.name
        
        if let description = product.description {
            productDescriptionLabel.text = product.description
        } else {
            productDescriptionTitleLabel.text = ""
            productDescriptionLabel.text = ""
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func callCompanyButtonDidTouch(sender: UIButton) {
        let phoneNumber = product.company.phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var alert = UIAlertController(title: "Anrufen", message: "Willst du \(product.company.name) wirklich anrufen?", preferredStyle: .Alert)
        
        alert.addAction(
            UIAlertAction(title: "Ja", style: .Default, handler: { (action: UIAlertAction!) in
                if let url = NSURL(string: "tel:\(phoneNumber)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            })
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
