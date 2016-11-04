//
//  StudentAnnotation.swift
//  On The Map
//
//  Created by Paul Crompton on 9/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class StudentAnnotation: MKPointAnnotation {
    let student: StudentInformation
    init(student: StudentInformation) {
        self.student = student
        super.init()
        let lat = CLLocationDegrees(student.latitude!)
        let long = CLLocationDegrees(student.longitude!)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let firstName: String
        if let name = student.firstName {
            firstName = name
        } else {
            firstName = ""
        }
        let lastName: String
        if let name = student.lastName {
            lastName = name
        } else {
            lastName = ""
        }
        self.title = "\(firstName) \(lastName)"
        if let subtitle = student.mediaURLString {
            self.subtitle = subtitle
        } else {
            self.subtitle = ""
        }
    }
}
