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
    
    var coordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionIndicator: UIActivityIndicatorView!
    
    var mapTabBarController: MapTabBarController?
    
    var viewDisplaced = false
    var displacement: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapStringTextField.delegate = self
        mediaURLTextField.delegate = self
        
        if let loginSession = UdacityClient.LoginSession.currentLoginSession {
            userName.text = "\(loginSession.user.firstName) \(loginSession.user.lastName)"
        }
        
//        mapStringTextField.text = "Lowell, MA"
//        mediaURLTextField.text = "http://cromptonmusic.com"
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findOnMapButton(_ sender: AnyObject) {
        
        setLocation() {
            if self.coordinate != nil {
                let annotation = MKPointAnnotation()
                self.coordinate = annotation.coordinate
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    func setLocation(completion: (() -> Void)?) {
       
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.mapStringTextField.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
  
            guard error == nil else {
                fatalError("Could not complete search")
            }
            guard let response = response else {
                fatalError("No response found")
            }
            if let location = response.mapItems.first {
                self.coordinate = location.placemark.coordinate
            }
            completion?()
        }
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        actionIndicator.startAnimating()
        if coordinate == nil {
            setLocation() {
                performUpdatesOnMain {
                    guard let coordinate = self.coordinate else {
                        fatalError("Unable to get coordinate")
                    }
                    if let loginSession = UdacityClient.LoginSession.currentLoginSession {
                        
                        let uniqueKey = loginSession.user.userId
                        let firstName = loginSession.user.firstName
                        let lastName = loginSession.user.lastName
                        let mapString = self.mapStringTextField.text
                        let mediaURL = URL(string: self.mediaURLTextField.text!)
                        let latitude = coordinate.latitude
                        let longitude = coordinate.longitude
                        
                        ParseClient.StudentInformation.get(by: uniqueKey, { (objectId) in
                            performUpdatesOnMain {
                                let student = ParseClient.StudentInformation.init(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
                                
                                student.post(completion: {
                                    performUpdatesOnMain {
                                        self.mapTabBarController?.refreshButton(self)
                                        self.actionIndicator.stopAnimating()
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            }
                        })
                        
                    } else {
                        fatalError("No login session found")
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Mark: Keyboard Functions
    
    override func keyboardWillShow(_ notification: Notification) {

    }
    
    override func keyboardWillHide(_ notification: Notification) {

    }

}
