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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapStringTextField.delegate = self
        mediaURLTextField.delegate = self
        
        if let loginSession = UdacityClient.LoginSession.currentLoginSession {
            userName.text = "\(loginSession.user.firstName) \(loginSession.user.lastName)"
        }
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findOnMapButton(_ sender: AnyObject) {
        actionIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        setLocation() {(errorMessage) in
            performUpdatesOnMain {
                self.actionIndicator.stopAnimating()
                if let errorMessage = errorMessage {
                    self.presentError(title: "Error Finding Location", errorMessage: errorMessage)
                    return
                }
                if let coordinate = self.coordinate {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                }
            }

        }
    }

    func setLocation(completion: ((_ errorMessage: String?) -> Void)?) {
        mapStringTextField.resignFirstResponder()
        mediaURLTextField.resignFirstResponder()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.mapStringTextField.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            performUpdatesOnMain {
                if let error = error {
                    completion?(error.localizedDescription)
                    return
                }
                guard let response = response else {
                    completion?("No response found")
                    return
                }
                if let location = response.mapItems.first {
                    self.coordinate = location.placemark.coordinate
                    let origin = CLLocationCoordinate2D(latitude: self.coordinate!.latitude + 2.5, longitude: self.coordinate!.longitude - 3.5)
                    let mapPoint = MKMapPointForCoordinate(origin)
                    let mapSize = MKMapSizeMake(5000000.0, 5000000.0)
                    let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
                    self.mapView.setVisibleMapRect(mapRect, animated: true)
                }
                completion?(nil)
            }
        }
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        actionIndicator.startAnimating()
        guard mediaURLTextField.text != "" else {
            actionIndicator.stopAnimating()
            presentError(title: "No Website Entered", errorMessage: "Please enter a valid URL in the Website text field")
            return
        }
        setLocation() {(errorMessage) in
            performUpdatesOnMain {
                if let errorMessage = errorMessage {
                    self.actionIndicator.stopAnimating()
                    self.presentError(title: "Error Finding Location", errorMessage: errorMessage)
                    return
                }
                guard let coordinate = self.coordinate else {
                    self.actionIndicator.stopAnimating()
                    self.presentError(title: "Error Finding Coordinate", errorMessage: "Unable to find coordinate")
                    return
                }
                if let loginSession = UdacityClient.LoginSession.currentLoginSession {
                    
                    let uniqueKey = loginSession.user.userId
                    let firstName = loginSession.user.firstName
                    let lastName = loginSession.user.lastName
                    let mapString = self.mapStringTextField.text
                    let mediaURL = self.mediaURLTextField.text
                    let latitude = coordinate.latitude
                    let longitude = coordinate.longitude
                    
                    ParseClient.StudentInformation.get(by: uniqueKey) { (objectId, errorMessage) in
                        performUpdatesOnMain {
                            if let errorMessage = errorMessage {
                                self.presentError(title: "Failed to Post Student Information", errorMessage: errorMessage)
                                return
                            }
                            let student = ParseClient.StudentInformation.init(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
                            
                            student.post() {(errorMessage) in
                                performUpdatesOnMain {
                                    self.actionIndicator.stopAnimating()
                                    
                                    if let errorMessage = errorMessage {
                                        self.presentError(title: "Error Completing Request", errorMessage: errorMessage)
                                    } else {
                                        self.mapTabBarController?.refreshButton(self)
                                        
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    self.presentError(title: "No Login Session Found", errorMessage: "Please login")
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    self.present(loginVC, animated: true, completion: nil)
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
    override func keyboardWillShow(_ notification: Notification) {}
    override func keyboardWillHide(_ notification: Notification) {}

}
