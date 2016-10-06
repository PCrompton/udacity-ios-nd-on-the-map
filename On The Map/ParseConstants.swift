//
//  ParseConstants.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let AppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        
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
        static let StudentLocation = "/StudentLocation"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
    }
    
    // MARK: Paremeter Values
    struct ParameterValues {
        static let Limit = 100
        
        static func Where(uniqueKey: String) -> String {
            return "{\"\(StudentInformation.StudentKeys.uniqueKey)\":\"\(uniqueKey)\"}"
        }
    }
    
    struct HTTPHeaderKeys {
        static let AppId = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
    }

}
