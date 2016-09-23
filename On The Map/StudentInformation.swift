//
//  StudentInformation.swift
//  On The Map
//
//  Created by Paul Crompton on 9/22/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {
    
    public static var students = [StudentInformation]()
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: URL?
    let latitude: Double
    let longitude: Double
    
    init(jsonDict: [String:Any?]) {
        
        objectId = jsonDict[StudentKeys.objectId] as! String
        uniqueKey = jsonDict[StudentKeys.uniqueKey] as! String
        firstName = jsonDict[StudentKeys.firstName] as! String
        lastName = jsonDict[StudentKeys.lastName] as! String
        mapString = jsonDict[StudentKeys.mapString] as! String
        mediaURL = URL(string: jsonDict[StudentKeys.mediaURL] as! String)
        latitude = jsonDict[StudentKeys.latitude] as! Double
        longitude = jsonDict[StudentKeys.longitude] as! Double
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
        let client = ParseClient.sharedInstance()
        
        let task = client.taskForGETMethod(ParseClient.Methods.StudentLocation, parameters: [ParseClient.ParameterKeys.Limit: ParseClient.ParameterValues.Limit], completionHandlerForGET: { (results, error) in
            
            guard let results = results?["results"] as? [[String: Any]] else {
                fatalError("No key \"results\" found")
            }
            for result in results {
                let student = StudentInformation(jsonDict: result)
                students.append(student)
            }
            completion?()
        })
        task.resume()
    }
    
    private struct StudentKeys {
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
