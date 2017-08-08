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
    
    // Mark: Functions
    func createAndRunTask(for request: URLRequest, with completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else {
                completion(data, nil, error)
                return
            }
            
            guard (error == nil) else {
                completion(nil, response, error)
                return
            }
            
            guard let data = data else {
                completion(nil, response, error)
                return
            }
            
            completion(data, response, nil)
            
        }
        task.resume()
    }
    
    func getJson(for request: URLRequest, with completion: @escaping (_ result: [String: Any]?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) {
        createAndRunTask(for: request) { (data, response, error) in
            guard (error == nil) else {
                completion(nil, response, error)
                return
            }
            
            guard let data = data else {
                completion(nil, response, error)
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, response: response, completionHandlerForConvertData: completion)
        }
    }
    
    func createRequest(for url: URL, as type: HTTPMethod?, with headers: [String: String]?, with body: String?) -> URLRequest {
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let type = type {
            request.httpMethod = type.rawValue
        }
        if let body = body {
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        return request
    }
    
    func serializeDataToJson(data: Data) throws -> [String: Any]? {
        let parsedResult: [String: Any]?
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return parsedResult
    }
    
    func convertDataWithCompletionHandler(data: Data, response: HTTPURLResponse?, completionHandlerForConvertData: (_ result: [String: Any]?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) {
        let parsedResult: [String: Any]?
        do {
            parsedResult = try serializeDataToJson(data: data)
            completionHandlerForConvertData(parsedResult, response, nil)
        } catch {
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            convertDataWithCompletionHandler(data: newData, response: response, completionHandlerForConvertData: { (result, response, error) in
                if error != nil {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                    completionHandlerForConvertData(nil, response, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
                } else {
                    completionHandlerForConvertData(result, response, error)
                }

            })
        }
    }
}
