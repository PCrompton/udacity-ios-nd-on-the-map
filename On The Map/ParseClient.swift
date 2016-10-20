//
//  ParseClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class ParseClient: SuperClient {

    // MARK: Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    class func post(student: StudentInformation, completion: ((_ errorMessage: String?) -> Void)?) {
        let httpMethod: SuperClient.HTTPMethod
        let apiMethod: String
        if let objectId = student.objectId {
            httpMethod = SuperClient.HTTPMethod.put
            apiMethod = "\(ParseClient.Methods.StudentLocation)/\(objectId)"
        } else {
            httpMethod = SuperClient.HTTPMethod.post
            apiMethod = ParseClient.Methods.StudentLocation
        }
        
        let url = StudentInformation.client.getURL(for: ParseClient.Constants.urlComponents, with: apiMethod, with: nil)
        let headers = [
            ParseClient.HTTPHeaderKeys.ApiKey: ParseClient.Constants.ApiKey,
            ParseClient.HTTPHeaderKeys.AppId: ParseClient.Constants.AppId,
            SuperClient.HTTPHeaderKeys.contentType: SuperClient.HTTPHeaderValues.json
        ]
        let request = ParseClient.createRequest(for: url, as: httpMethod, with: headers, with: student.body)
        StudentInformation.client.createAndRunTask(for: request) { (results, error) in
            performUpdatesOnMain {
                guard let results = results else {
                    completion?("No results returned")
                    return
                }
                if httpMethod == SuperClient.HTTPMethod.post {
                    guard results["objectId"] as? String != nil else {
                        completion?("no \"objectId\" field found")
                        return
                    }
                    guard results["createdAt"] as? String != nil else {
                        completion?("no \"createdAt\" field found")
                        return
                    }
                } else if httpMethod == SuperClient.HTTPMethod.put {
                    guard results["updatedAt"] != nil else {
                        completion?("no \"updatedAt\" field found")
                        return
                    }
                }
                completion?(nil)
            }
        }
    }
    
    class func get(by uniqueKey: String, _ completion: @escaping ((_ objectId: String?, _ errorMessage: String?) -> Void)) {
        let method = ParseClient.Methods.StudentLocation
        let parameters = [ParseClient.ParameterKeys.Where: ParseClient.ParameterValues.Where(uniqueKey: uniqueKey)]
        let url = URL(string: StudentInformation.client.getURL(for: ParseClient.Constants.urlComponents, with: method, with: parameters).absoluteString.replacingOccurrences(of: "%22:%22", with: "%22%3A%22"))!
        let httpHeaders = [ParseClient.HTTPHeaderKeys.ApiKey: ParseClient.Constants.ApiKey, ParseClient.HTTPHeaderKeys.AppId: ParseClient.Constants.AppId]
        let request = ParseClient.createRequest(for: url, as: SuperClient.HTTPMethod.get, with: httpHeaders, with: nil)
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
        let parameters: [String: Any] = [ParseClient.ParameterKeys.Limit: ParseClient.ParameterValues.Limit, ParseClient.ParameterKeys.Order: ParseClient.ParameterValues.Order]
        let url = ParseClient.sharedInstance().getURL(for: ParseClient.Constants.urlComponents, with: ParseClient.Methods.StudentLocation, with: parameters)
        let headers = [
            ParseClient.HTTPHeaderKeys.ApiKey: ParseClient.Constants.ApiKey,
            ParseClient.HTTPHeaderKeys.AppId: ParseClient.Constants.AppId
        ]
        let request = createRequest(for: url, as: SuperClient.HTTPMethod.get, with: headers, with: nil)
        ParseClient.sharedInstance().createAndRunTask(for: request) { (results, error) in
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
}
