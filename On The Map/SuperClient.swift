//
//  SuperClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class SuperClient: NSObject {
    // MARK: Properties
    var session = URLSession.shared
    //var config = ParseConfig()
    
    override init() {
        super.init()
    }
    
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: [String: Any]?, _ error: NSError?) -> Void) {
        let parsedResult: [String: Any]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
    }

}
