//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    struct HTTPBody {
        let username: String
        let password: String
        
        var body: String {
            get {
                return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
            }
        }
    }
    struct LoginSession {
        
        static var currentLoginSession: LoginSession?
        
        let id: String
        let expiration: String
        let user: User
    }
    
    struct User {
        let userId: String
        let firstName: String
        let lastName: String
    }
}
