//
//  Company.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 23/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation

struct Company {
    var id: Int
    var name: String
    var street: String
    var zipCode: String
    var locality: String
    var phoneNumber: String
    var email: String
    
    var fullAddress: String {
        return "\(street), \(zipCode), \(locality)"
    }
    
    init(id: Int, name: String, street: String, zipCode: String, locality: String, phoneNumber: String, email: String) {
        self.id = id
        self.name = name
        self.street = street
        self.zipCode = zipCode
        self.locality = locality
        self.phoneNumber = phoneNumber
        self.email = email
    }
}