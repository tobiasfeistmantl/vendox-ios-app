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
    var nextPage = 1
    var locationManager = CLLocationManager()
    var location: CLLocation?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var loadProductsActivityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initRefreshControl()
        initDelegation()
        initSearchBar()
        initLoadProductsActivityIndicator()
        
        let navigationRectangle = CGRectMake(0, 0, 100, 22.63)
        
        let navigationImage = UIImageView(frame: navigationRectangle)
        navigationImage.image = UIImage(named: "Brand Name White Navigation Bar")!
        
        let workaroundImageView = UIImageView(frame: navigationRectangle)
        workaroundImageView.addSubview(navigationImage)
        
        navigationItem.titleView = workaroundImageView
        
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            refreshProducts()
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

        if let formattedPrice = product.formattedPrice() {
            cell.productPriceLabel.text = formattedPrice
        } else {
            cell.productPriceLabel.text = "Preis auf Nachfrage"
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
        
        API.setNewLocation(locationManager.location)
        
        refreshProducts()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        refreshProducts()
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            refreshProducts()
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if maximumOffset - currentOffset <= -40 {
            getProducts()
        }
    }
    
    func getProducts() {
        API.getProducts(searchValue: searchBar.text, page: nextPage) { (products, errors) in
            self.products += products
            self.tableView.reloadData()
            
            if products.count != 0 {
                self.nextPage += 1
            }
            
            self.refreshControl?.endRefreshing()
            self.loadProductsActivityIndicator.stopAnimating()
        }
    }
    
    func refreshProducts() {
        if products.count == 0 {
            loadProductsActivityIndicator.startAnimating()
        }
        
        nextPage = 1
        
        API.getProducts(searchValue: searchBar.text, page: nextPage) { (products, errors) in
            self.products = products
            self.tableView.reloadData()
            
            self.refreshControl?.endRefreshing()
            self.loadProductsActivityIndicator.stopAnimating()
        }
        
        nextPage += 1
    }
    
    func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshProducts", forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Produkte in deiner Nähe werden geladen")
        self.refreshControl = refreshControl
    }
    
    func initDelegation() {
        locationManager.delegate = self
        searchBar.delegate = self
    }
    
    func initSearchBar() {
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func initLoadProductsActivityIndicator() {
        loadProductsActivityIndicator.center = tableView.center
        loadProductsActivityIndicator.color = .grayColor()
        tableView.addSubview(loadProductsActivityIndicator)
    }
}
