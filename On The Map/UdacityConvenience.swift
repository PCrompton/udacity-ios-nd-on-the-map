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
        
        func getHTTPBody() -> String {
            return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        }
        func login(sender: LoginViewController, completion: (() -> Void)?) {
            let client = UdacityClient.sharedInstance()
            let task = client.taskForPOSTMethod(Methods.session, body: self.getHTTPBody(), completionHandlerForPOST: { (result, error) in
                guard error == nil else {
                    fatalError("An error was found: \(error!)")
                }
                guard let result = result else {
                    fatalError("No result found")
                }
                guard let account = result["account"] as? [String: Any] else {
                    fatalError("Failed to retrieve account")
                }
                guard let registered = account["registered"] as? Bool else {
                    fatalError("Failed to retrieve registered status")
                }
                guard registered == true else {
                    fatalError("User not registered")
                }
                guard let userId = account["key"] as? String else {
                    fatalError("Failed to retrieve key")
                }
                guard let session = result["session"] as? [String: Any] else {
                    fatalError("Failed to retrieve session")
                }
                guard let sessionId = session["id"] as? String else {
                    fatalError("Failed to retrieve 'id' in session")
                }
                guard let expiration = session["expiration"] as? String else {
                    fatalError("Failed to retrieve 'expiration' in session")
                }
                let url = client.getURL(for: Constants.urlComponents, with: "\(Methods.users)/\(userId)", with: nil)
                let task = client.createTask(for: url, as: HTTPMethod.get, with: nil) { (result, error) in
                    guard error == nil else {
                        fatalError("Error getting request \(error)")
                    }
                    guard let result = result else {
                        fatalError("Result not found")
                    }
                    guard let user = result["user"] as? [String: Any] else {
                        fatalError("User not found")
                    }
                    guard let lastName = user["last_name"] as? String else {
                        fatalError("Last name not found")
                    }
                    guard let firstName = user["first_name"] as? String else {
                        fatalError("First name not found")
                    }
                    sender.loginSession = LoginSession(id: sessionId, expiration: expiration, user: User(userId: userId, firstName: firstName, lastName: lastName))
                }
                task.resume()
            })
            task.resume()
            completion?()
        }
    }
    
    struct LoginSession {
        let id: String
        let expiration: String
        let user: User
    }
    
    struct User {
        let userId: String
        let firstName: String
        let lastName: String
    }
}
