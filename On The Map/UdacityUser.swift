//
//  UdacityUser.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct User {
        
        let userId: String
        let firstName: String
        let lastName: String
        
        init(userId: String) {
            self.userId = userId
            
            
            let session = URLSession.shared
            
            
            self.firstName = ""
            self.lastName = ""
        }
    }
}
