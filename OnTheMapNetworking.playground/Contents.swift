//: Playground - noun: a place where people can play
import Foundation
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: Constants
struct Constants {
    
    // MARK: API Key
    static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let AppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    // MARK: URLs
    static let ApiScheme = "https"
    static let ApiHost = "parse.udacity.com"
    static let ApiPath = "/parse/classes"
}

var components = URLComponents()
components.scheme = Constants.ApiScheme
components.host = Constants.ApiHost
components.path = Constants.ApiPath
components.queryItems = [URLQueryItem(name: "limit", value: "10")]
let url = components.url!
print(url)
let session = URLSession.shared
var request = URLRequest(url: url)
request.addValue(Constants.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
        guard (error == nil) else {
                fatalError("\(error)")
            }
        
        guard let data = data else {
            fatalError("No data found")
        }
        print(data)
        let parsedResult: Any
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            fatalError("Could not parse the data as JSON: '\(data)'")
        }
        print(parsedResult)
    })
task.resume()




