//
//  StudentInformation.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {
    public struct StudentInformation {
    
        public static let client = ParseClient.sharedInstance()
        public static var students = [StudentInformation]()
        
        let objectId: String?
        let uniqueKey: String
        let firstName: String
        let lastName: String
        let mapString: String?
        let mediaURL: URL?
        let latitude: Double?
        let longitude: Double?
        
        var body: String {
            get {
                return "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!.absoluteString)\", \"latitude\": \(latitude!), \"longitude\": \(longitude!)}"
            }
        }
        
        init(jsonDict: [String:Any?]) {
            
            objectId = jsonDict[StudentKeys.objectId] as! String?
            uniqueKey = jsonDict[StudentKeys.uniqueKey] as! String
            firstName = jsonDict[StudentKeys.firstName] as! String
            lastName = jsonDict[StudentKeys.lastName] as! String
            if let result = jsonDict[StudentKeys.mapString] as? String {
                mapString = result
            } else {
                mapString = nil
            }
            if let result = jsonDict[StudentKeys.mediaURL] as? String {
                mediaURL = URL(string: result)
            } else {
                mediaURL = nil
            }
            if let result = jsonDict[StudentKeys.latitude] as? Double {
                latitude = result
            } else {
                latitude = nil
            }
            if let result = jsonDict[StudentKeys.longitude] as? Double {
                longitude = result
            } else {
                longitude = nil
            }
        }
        
        init(objectId: String?,
             uniqueKey: String,
             firstName: String,
             lastName: String,
             mapString: String?,
             mediaURL: URL?,
             latitude: Double?,
             longitude: Double?
            ) {
            self.objectId = objectId
            self.uniqueKey = uniqueKey
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            
        }
        
        func openMediaURL(sender: UIViewController) {
            if let url = mediaURL {
                UIApplication.shared.open(url, options: [:])
            } else {
                let alertController = UIAlertController(title: "Valid URL not found", message: "\(mediaURL) not a valid URL", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .cancel , handler: nil)
                alertController.addAction(alertAction)
                sender.present(alertController, animated: true, completion: nil)
            }

        }

        public static func fetchStudents(completion: (() -> Void)?) {
            students.removeAll()
            let parameters = [ParameterKeys.Limit: ParameterValues.Limit]
            let url = client.getURL(for: Constants.urlComponents, with: Methods.StudentLocation, with: parameters)
            let headers = [
                HTTPHeaderKeys.ApiKey: Constants.ApiKey,
                HTTPHeaderKeys.AppId: Constants.AppId
            ]
        
            client.createAndRunTask(for: url, as: HTTPMethod.get, with: headers, with: nil) { (results, error) in
                guard let results = results?["results"] as? [[String: Any]] else {
                    fatalError("No key \"results\" found")
                }
                for result in results {
                    let student = StudentInformation(jsonDict: result)
                    if student.longitude != nil && student.latitude != nil {
                        students.append(student)
                    }
                }
                completion?()
            }
        }
        
        func post(completion: (() -> Void)?) {
            
            let httpMethod: HTTPMethod
            let apiMethod: String
            if objectId != nil {
                httpMethod = HTTPMethod.put
                apiMethod = "\(Methods.StudentLocation)/\(objectId)"
            } else {
                httpMethod = HTTPMethod.post
                apiMethod = Methods.StudentLocation
            }
            
            let url = StudentInformation.client.getURL(for: Constants.urlComponents, with: apiMethod, with: nil)
            let headers = [
                HTTPHeaderKeys.ApiKey: Constants.ApiKey,
                HTTPHeaderKeys.AppId: Constants.AppId,
                SuperClient.HTTPHeaderKeys.contentType: HTTPHeaderValues.json
            ]
            StudentInformation.client.createAndRunTask(for: url, as: httpMethod, with: headers, with: body) { (results, error) in
                guard let results = results else {
                    fatalError("No results returned")
                }
                for (key, value) in results {
                    print("\(key): \(value)")
                }
                
                guard results["objectId"] as? String != nil else {
                    fatalError("no \"objectId\" field found")
                }
                guard results["createdAt"] as? String != nil else {
                    fatalError("no \"createdAt\" field found")
                }

               completion?()
            }
        }
        
        static func get(by uniqueKey: String, _ completion: @escaping ((_ objectId: String?) -> Void)) {
            let method = Methods.StudentLocation
            let parameters = [ParameterKeys.Where: ParameterValues.Where(uniqueKey: uniqueKey)]
            let url = URL(string: StudentInformation.client.getURL(for: Constants.urlComponents, with: method, with: parameters).absoluteString.replacingOccurrences(of: "%22:%22", with: "%22%3A%22"))!
            print(url.absoluteString)
            print(parameters)
            let httpHeaders = [HTTPHeaderKeys.ApiKey: Constants.ApiKey, HTTPHeaderKeys.AppId: Constants.AppId]
            StudentInformation.client.createAndRunTask(for: url, as: HTTPMethod.get, with: httpHeaders, with: nil) { (results, error) in
                performUpdatesOnMain {
                    guard error == nil else {
                        fatalError("No Results Found")
                    }
                    if let objectId = results?[StudentKeys.objectId] as? String {
                        completion(objectId)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        
        struct StudentKeys {
            static let objectId = "objectId"
            static let uniqueKey = "uniqueKey"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mapString = "mapString"
            static let mediaURL = "mediaURL"
            static let latitude = "latitude"
            static let longitude = "longitude"
        }
    }
}
