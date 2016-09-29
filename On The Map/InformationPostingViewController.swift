//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    var loginSession: UdacityClient.LoginSession? = nil
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var mapStringTextField: UITextField!
    
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loginSession = loginSession {
            userName.text = "\(loginSession.user.firstName) \(loginSession.user.lastName)"
        }
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findOnMapButton(_ sender: AnyObject) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = mapStringTextField.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard (error == nil) else {
                fatalError("Could not complete search")
            }
            
            guard let response = response else {
                fatalError("No response found")
            }
            
            if let location = response.mapItems.first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.placemark.coordinate
                self.mapView.addAnnotation(annotation)
                
            }

            
        }
        
    }

    @IBAction func submitButton(_ sender: AnyObject) {
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

}
