//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        static var urlComponents: URLComponents {
            get {
                var components = URLComponents()
                components.scheme = ApiScheme
                components.host = ApiHost
                components.path = ApiPath
                return components
            }
        }
    }
    
    struct Methods {
        static let session = "/session"
        static let users = "/users"
    }
    
    struct HTTPHeaderKeys {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
    
    struct HTTPHeaderValues {
        static let json = "application/json"
    }
    
}
