//
//  StudentInformation.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit


public struct StudentInformation {

    static var client = ParseClient()
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

