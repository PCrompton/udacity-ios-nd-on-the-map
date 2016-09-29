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
    let student: ParseClient.StudentInformation
    init(student: ParseClient.StudentInformation) {
        self.student = student
        super.init()
        let lat = CLLocationDegrees(student.latitude!)
        let long = CLLocationDegrees(student.longitude!)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = "\(student.firstName) \(student.lastName)"
        self.subtitle = student.mediaURL?.absoluteString
    }
}
