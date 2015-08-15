//
//  APIError.swift
//  Lome
//
//  Created by Tobias Feistmantl on 05/08/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APIError {
    var type: String
    var specific: JSON?
    
    init(type: String, specific: JSON?) {
        self.type = type
        self.specific = specific
    }
    
    init(_ jsonData: JSON) {
        let errorData = jsonData["error"]
        
        let type = errorData["type"].string!
        let specific = errorData["specific"]
        
        self.init(type: type, specific: specific)
    }
}