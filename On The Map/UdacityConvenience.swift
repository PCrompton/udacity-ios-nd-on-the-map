//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    struct HTTPBody {
        let username: String
        let password: String
        
        var body: String {
            get {
                return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
            }
        }
        func login(completion: ((_ error: Error?) -> Void)?) {
            let client = UdacityClient.sharedInstance()
            let url = client.getURL(for: Constants.urlComponents, with: "\(Methods.session)", with: nil)
            let httpHeaders = [HTTPHeaderKeys.accept: HTTPHeaderValues.json, HTTPHeaderKeys.contentType: HTTPHeaderValues.json]
            let request = client.createRequest(for: url, as: HTTPMethod.post, with: httpHeaders, with: body)
          
            client.createAndRunTask(for: request) { (result, error) in
                
                performUpdatesOnMain {
                    guard error == nil else {
                        completion?(error)
                        return
                    }
                    guard let result = result else {
                        completion?(error)
                        return
                    }
                    
                    if let serverError = result["error"] as? String {
                        completion?(NSError(domain: serverError, code: 0))
                        return
                    }
                    
                    guard let account = result["account"] as? [String: Any] else {
                        completion?(NSError(domain: "Failed to retrieve account", code: 1))
                        return
                    }
                    guard let registered = account["registered"] as? Bool else {
                        completion?(NSError(domain: "Failed to retrieve registered status", code: 1))
                        return
                    }
                    guard registered == true else {
                        completion?(NSError(domain: "User not registered", code: 1))
                        return
                    }
                    guard let userId = account["key"] as? String else {
                        completion?(NSError(domain: "Failed to retrieve key", code: 1))
                        return
                    }
                    guard let session = result["session"] as? [String: Any] else {
                        completion?(NSError(domain: "Failed to retrieve session", code: 1))
                        return
                    }
                    guard let sessionId = session["id"] as? String else {
                        completion?(NSError(domain: "Failed to retrieve \"id\" in session", code: 1))
                        return
                    }
                    guard let expiration = session["expiration"] as? String else {
                        completion?(NSError(domain: "Failed to retrieve 'expiration' in session", code: 1))
                        return
                    }
                    
                    let url = client.getURL(for: Constants.urlComponents, with: "\(Methods.users)/\(userId)", with: nil)
                    let request = client.createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
                    client.createAndRunTask(for: request, taskCompletion: { (result, error) in
                        performUpdatesOnMain {
                            guard error == nil else {
                                completion?(error)
                                return
                            }
                            guard let result = result else {
                                completion?(NSError(domain: "Result not found", code: 1))
                                return
                            }
                            guard let user = result["user"] as? [String: Any] else {
                                completion?(NSError(domain: "User not found", code: 1))
                                return
                            }
                            guard let lastName = user["last_name"] as? String else {
                                completion?(NSError(domain: "Last name not found", code: 1))
                                return
                            }
                            guard let firstName = user["first_name"] as? String else {
                                completion?(NSError(domain: "First name not found", code: 1))
                                return
                            }
                            UdacityClient.LoginSession.currentLoginSession = LoginSession(id: sessionId, expiration: expiration, user: User(userId: userId, firstName: firstName, lastName: lastName))
                            completion?(nil)
                        }
                    })
                }
            }
        }
    }
    
    struct LoginSession {
        
        static var currentLoginSession: LoginSession?
        
        let id: String
        let expiration: String
        let user: User
    }
    
    struct User {
        let userId: String
        let firstName: String
        let lastName: String
    }
    
    func getUser(by id: String) {
        
    }
}
