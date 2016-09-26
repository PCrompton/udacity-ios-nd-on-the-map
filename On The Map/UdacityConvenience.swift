//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct HTTPBody {
        let username: String
        let password: String
        
        func getHTTPBody() -> String {
            return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        }
    }
    
    struct LoginSession {
        let id: String
        let expiration: String
        
    }
}
