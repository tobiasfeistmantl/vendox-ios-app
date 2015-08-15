//
//  UserAccount.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 14/08/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON

class UserAccount {
    static let keychain = Keychain(service: "vendox.session")
    
    class Session {
        static var id: Int? {
            set {
                if let newValue = newValue {
                    keychain["sessionId"] = "\(newValue)"
                } else {
                    keychain["sessionId"] = nil
                }
            }
            
            get {
                if let id = keychain["sessionId"] {
                    return id.toInt()
                }
                
                return nil
            }
        }
        
        static var token: String? {
            set {
            keychain["sessionToken"] = newValue
            }
            
            get {
                return keychain["sessionToken"]
            }
        }
        
        static func create(responseHander: (APIError?, NSError?) -> Void) {
            API.Users.Sessions.create(UIDevice.currentDevice().model) { (session, apiError, errors) in
                println(session)

                if let session = session {
                    UserAccount.Session.id = session["id"].int
                    UserAccount.Session.token = session["token"].string
                }
                
                responseHander(apiError, errors)
            }
        }
    }
}