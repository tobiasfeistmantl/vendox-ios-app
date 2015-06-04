//
//  ProductsTableViewController.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 23/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import UIKit
import CoreLocation

class ProductsTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    var products: [Product] = []
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "getProducts", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        
        locationManager.delegate = self
        searchBar.delegate = self
        
        searchBar.enablesReturnKeyAutomatically = false
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            getProducts()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductCell", forIndexPath: indexPath) as! ProductTableViewCell

        let product = products[indexPath.row]
        
        cell.product = product
        cell.productNameLabel.text = product.name
        cell.productCompanyNameLabel.text = product.company.name

        if product.formattedPrice() != nil {
            cell.productPriceLabel.text = product.formattedPrice()!
        } else {
            cell.productPriceLabel.text = "Preis auf Nachfrage"
            cell.productPriceLabel.textColor = UIColor.grayColor()
        }
        
        cell.productImageView.image = product.image
        
        if let distanceToUser = product.distanceToUser {
            cell.productDistanceToUserLabel.text = "\(distanceToUser) km"
        } else {
            cell.productDistanceToUserLabel.text = ""
        }

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProduct" {
            let cell = sender as! ProductTableViewCell
            let destinationController = segue.destinationViewController as! ProductViewController
            
            destinationController.product = cell.product
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        
        getProducts()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        getProducts()
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            getProducts()
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func getProducts() {
        let refreshControlYOffset = -(UIApplication.sharedApplication().statusBarFrame.size.height + navigationController!.navigationBar.frame.height + refreshControl!.frame.height)
        
        tableView.setContentOffset(CGPointMake(0, refreshControlYOffset), animated: true)
        refreshControl?.beginRefreshing()
        
        API.getProducts(searchValue: searchBar.text, location: locationManager.location) { (products, errors) in
            self.products = products
            self.tableView.reloadData()
            
            self.refreshControl?.endRefreshing()
        }
    }
    
}
