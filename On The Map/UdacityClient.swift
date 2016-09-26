//
//  UdacityClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class UdacityClient: SuperClient {

    func taskForPOSTMethod(_ method: String, body: String, completionHandlerForPOST: @escaping (_ result: [String: Any]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let session = URLSession.shared
        let request = createPostRequest(with: body)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (error == nil) else {
                fatalError("\(error)")
            }
            
            guard let data = data else {
                fatalError("No data found")
            }
            let newData = data.subdata(in: Range(5...data.count))
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForPOST)
        })
        
        return task
    }
    
    func createPostRequest(with body: String) -> URLRequest {
        var request = URLRequest(url: udacityClientURL(from: nil))
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(HTTPHeaderValues.json, forHTTPHeaderField: HTTPHeaderKeys.accept)
        request.addValue(HTTPHeaderValues.json, forHTTPHeaderField: HTTPHeaderKeys.contentType)
        request.httpBody = body.data(using: String.Encoding.utf8)
        return request
    }
    
    // Mark: Helper Functions
    fileprivate func udacityClientURL(from parameters: [String: Any]?, withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = "\(Constants.ApiPath)\(Methods.session)"
        components.queryItems = [URLQueryItem]()
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
