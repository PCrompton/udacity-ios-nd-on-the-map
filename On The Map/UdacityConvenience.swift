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
                print(result)
                guard (error == nil) else {
                    fatalError("An error was found: \(error!)")
                }
                
                guard let result = result else {
                    fatalError("No result found")
                }
                
                
                sender.loginSession = LoginSession(dictionary: result)
            })
            task.resume()
            completion?()
        }
        
    }
    
    struct LoginSession {
        let id: String
        let expiration: String
        
        let user: User
        
        init(dictionary: [String: Any]) {
            guard let account = dictionary["account"] as? [String: Any] else {
                fatalError("Failed to retrieve account")
            }
            
            guard let registered = account["registered"] as? Bool else {
                fatalError("Failed to retrieve registered status")
            }
            
            guard registered == true else {
                fatalError("User not registered")
            }
            
            guard let key = account["key"] as? String else {
                fatalError("Failed to retrieve account key")
            }
            
            guard let session = dictionary["session"] as? [String: Any] else {
                fatalError("Failed to retrieve session")
            }
            
            guard let id = session["id"] as? String else {
                fatalError("Failed to retrieve 'id' in session")
            }
            guard let expiration = session["expiration"] as? String else {
                fatalError("Failed to retrieve 'expiration' in session")
            }
            
            self.id = id
            self.expiration = expiration
            self.user = User(userId: key)
        }
    }
}
