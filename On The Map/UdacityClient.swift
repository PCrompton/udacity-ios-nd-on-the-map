//
//  UdacityClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class UdacityClient: SuperClient {
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    class func login(with username: String, password: String, completion: ((_ errorMessage: String?) -> Void)?) {
        let client = UdacityClient.sharedInstance()
        let url = client.getURL(for: Constants.urlComponents, with: "\(Methods.session)", with: nil)
        let httpHeaders = [HTTPHeaderKeys.accept: HTTPHeaderValues.json, HTTPHeaderKeys.contentType: HTTPHeaderValues.json]
        let request = UdacityClient.createRequest(for: url, as: HTTPMethod.post, with: httpHeaders, with: HTTPBody(username: username, password: password).body)
        
        client.createAndRunTask(for: request) { (result, error) in
            
            performUpdatesOnMain {
                guard error == nil else {
                    completion?(error!.localizedDescription)
                    return
                }
                guard let result = result else {
                    completion?(error!.localizedDescription)
                    return
                }
                
                if let serverError = result["error"] as? String {
                    completion?(serverError)
                    return
                }
                
                guard let account = result["account"] as? [String: Any] else {
                    completion?("Failed to retrieve account")
                    return
                }
                guard let registered = account["registered"] as? Bool else {
                    completion?("Failed to retrieve registered status")
                    return
                }
                guard registered == true else {
                    completion?("User not registered")
                    return
                }
                guard let userId = account["key"] as? String else {
                    completion?("Failed to retrieve key")
                    return
                }
                guard let session = result["session"] as? [String: Any] else {
                    completion?("Failed to retrieve session")
                    return
                }
                guard let sessionId = session["id"] as? String else {
                    completion?("Failed to retrieve \"id\" in session")
                    return
                }
                guard let expiration = session["expiration"] as? String else {
                    completion?("Failed to retrieve 'expiration' in session")
                    return
                }
                
                let url = client.getURL(for: Constants.urlComponents, with: "\(Methods.users)/\(userId)", with: nil)
                let request = UdacityClient.createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
                client.createAndRunTask(for: request, taskCompletion: { (result, error) in
                    performUpdatesOnMain {
                        guard error == nil else {
                            completion?(error!.localizedDescription)
                            return
                        }
                        guard let result = result else {
                            completion?("Result not found")
                            return
                        }
                        guard let user = result["user"] as? [String: Any] else {
                            completion?("User not found")
                            return
                        }
                        guard let lastName = user["last_name"] as? String else {
                            completion?("Last name not found")
                            return
                        }
                        guard let firstName = user["first_name"] as? String else {
                            completion?("First name not found")
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
