//
//  ParseClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    // MARK: Properties
    var session = URLSession.shared
    //var config = ParseConfig()
    
    override init() {
        super.init()
    }
    
    func taskForGETMethod(_ method: String, parameters: [String:Any], completionHandlerForGET: @escaping (_ result: [String: Any]?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        let session = URLSession.shared
        var request = URLRequest(url: parseClientURLFromParameters(parameters: parameters))
        request.addValue(Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (error == nil) else {
                fatalError("\(error)")
            }
            
            guard let data = data else {
                fatalError("No data found")
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerForGET)
        })
        
        return task
    }
    
    // Mark: Helper Functions
    fileprivate func parseClientURLFromParameters(parameters: [String: Any], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = "\(Constants.ApiPath)\(Methods.StudentLocation)"
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    fileprivate func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: [String: Any]?, _ error: NSError?) -> Void) {
        let parsedResult: [String: Any]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
