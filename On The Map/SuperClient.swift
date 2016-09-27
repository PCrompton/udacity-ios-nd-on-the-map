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
    
    func getURL(for urlComponents: URLComponents, with path: String?, with parameters: [String: Any]?) -> URL {
        
        var components = urlComponents
        if let path = path {
            components.path += path
        }
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    func createTask(for url: URL, as httpMethod: HTTPMethod?, with headers: [String:String]?, taskCompletion: @escaping (_ result: [String: Any]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let session = URLSession.shared
        let request = createRequest(for: url, with: headers)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (error == nil) else {
                fatalError("\(error)")
            }
            
            guard let data = data else {
                fatalError("No data found")
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: taskCompletion)
        })
        
        return task
    }
    
    func createRequest(for url: URL, with headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        return request
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
