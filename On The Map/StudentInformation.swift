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
        let mediaURLString: String?
        let latitude: Double?
        let longitude: Double?
        
        var mediaURL: URL? {
            get {
                if let mediaURLString = mediaURLString {
                    let mediaURLComponents = URLComponents(string: mediaURLString)
                    if var mediaURLComponents = mediaURLComponents {
                        if mediaURLComponents.scheme != nil {
                            if let url = mediaURLComponents.url {
                                return url
                            } 
                        } else {
                            mediaURLComponents.scheme = "http"
                            if let url = mediaURLComponents.url {
                                return url
                            }
                        }
                    }
                }
                return nil
            }
        }
        
        var body: String {
            get {
                return "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURLString!)\", \"latitude\": \(latitude!), \"longitude\": \(longitude!)}"
            }
        }
        
        // MARK: Init Methods
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
                mediaURLString = result
            } else {
                mediaURLString = nil
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
             mediaURL: String?,
             latitude: Double?,
             longitude: Double?
            ) {
            self.objectId = objectId
            self.uniqueKey = uniqueKey
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURLString = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            
        }
        
        // MARK: Instance Methods
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

        func post(completion: ((_ errorMessage: String?) -> Void)?) {
            let httpMethod: HTTPMethod
            let apiMethod: String
            if let objectId = objectId {
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
            let request = StudentInformation.client.createRequest(for: url, as: httpMethod, with: headers, with: body)
            StudentInformation.client.createAndRunTask(for: request) { (results, error) in
                performUpdatesOnMain {
                    guard let results = results else {
                        completion?("No results returned")
                        return
                    }
                    if httpMethod == HTTPMethod.post {
                        guard results["objectId"] as? String != nil else {
                            completion?("no \"objectId\" field found")
                            return
                        }
                        guard results["createdAt"] as? String != nil else {
                            completion?("no \"createdAt\" field found")
                            return
                        }
                    } else if httpMethod == HTTPMethod.put {
                        guard results["updatedAt"] != nil else {
                            completion?("no \"updatedAt\" field found")
                            return
                        }
                    }
                    completion?(nil)
                }
            }
        }
        
        static func get(by uniqueKey: String, _ completion: @escaping ((_ objectId: String?, _ errorMessage: String?) -> Void)) {
            let method = Methods.StudentLocation
            let parameters = [ParameterKeys.Where: ParameterValues.Where(uniqueKey: uniqueKey)]
            let url = URL(string: StudentInformation.client.getURL(for: Constants.urlComponents, with: method, with: parameters).absoluteString.replacingOccurrences(of: "%22:%22", with: "%22%3A%22"))!
            print(url.absoluteString)
            let httpHeaders = [HTTPHeaderKeys.ApiKey: Constants.ApiKey, HTTPHeaderKeys.AppId: Constants.AppId]
            let request = client.createRequest(for: url, as: HTTPMethod.get, with: httpHeaders, with: nil)
            StudentInformation.client.createAndRunTask(for: request) { (results, error) in
                performUpdatesOnMain {
                    guard error == nil else {
                        completion(nil, "Error Getting Student Information")
                        return
                    }
                    guard let results = results?["results"] as? [[String: Any]] else {
                        completion(nil, "Unable to retrieve results")
                        return
                    }
                    if results.count > 0 {
                        if let objectId = results[0]["objectId"] as? String {
                            completion(objectId, nil)
                        } else {
                            completion(nil, "Unable to get ObjectId")
                        }
                    } else {
                        completion(nil, "Unable to get Student Information")
                    }
                    
                }
            }
        }
        
        // MARK: Class Methods
        public static func fetchStudents(completion: ((_ errorMessage: String?) -> Void)?) {
            StudentInformation.students.removeAll()
            let parameters: [String: Any] = [ParameterKeys.Limit: ParameterValues.Limit, ParameterKeys.Order: ParameterValues.Order]
            let url = client.getURL(for: Constants.urlComponents, with: Methods.StudentLocation, with: parameters)
            let headers = [
                HTTPHeaderKeys.ApiKey: Constants.ApiKey,
                HTTPHeaderKeys.AppId: Constants.AppId
            ]
            let request = client.createRequest(for: url, as: HTTPMethod.get, with: headers, with: nil)
            client.createAndRunTask(for: request) { (results, error) in
                if let error = error {
                    completion?(error.localizedDescription)
                    return
                }
                guard let results = results?["results"] as? [[String: Any]] else {
                    completion?("No key \"results\" found")
                    return
                }
                for result in results {
                    let student = StudentInformation(jsonDict: result)
                    if student.longitude != nil && student.latitude != nil {
                        StudentInformation.students.append(student)
                    }
                }
                completion?(nil)
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
