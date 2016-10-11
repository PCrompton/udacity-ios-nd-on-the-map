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
        
        mapStringTextField.text = "Lowell, MA"
        mediaURLTextField.text = "http://cromptonmusic.com"
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findOnMapButton(_ sender: AnyObject) {
        mapView.removeAnnotations(mapView.annotations)
        setLocation() {(error) in
            performUpdatesOnMain {
                if let error = error {
                    self.presentNetworkError(title: "Error Finding Location", error: error)
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

    func setLocation(completion: ((_ error: Error?) -> Void)?) {
       
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.mapStringTextField.text
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            performUpdatesOnMain {
                guard error == nil else {
                    completion?(error)
                    return
                }
                guard let response = response else {
                    completion?(NSError(domain: "No response found", code: 1, userInfo: nil))
                    return
                }
                if let location = response.mapItems.first {
                    self.coordinate = location.placemark.coordinate
                }
                completion?(nil)
            }
        }
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        actionIndicator.startAnimating()
        setLocation() {(error) in
            performUpdatesOnMain {
                if let error = error {
                    self.actionIndicator.stopAnimating()
                    self.presentNetworkError(title: "Error Finding Location", error: error)
                    return
                }
                guard let coordinate = self.coordinate else {
                    self.actionIndicator.stopAnimating()
                    self.presentNetworkError(title: "Error Finding Coordinate", error: NSError(domain: "Unable to find coordinate", code: 1, userInfo: nil))
                    return
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
                            
                            student.post(completion: {(error) in
                                performUpdatesOnMain {
                                    self.actionIndicator.stopAnimating()
                                    
                                    if let error = error {
                                        self.presentNetworkError(title: "Error Completing Request", error: error)
                                    } else {
                                        self.mapTabBarController?.refreshButton(self)
                                        
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            })
                        }
                    })
                    
                } else {
                    self.presentNetworkError(title: "No Login Session Found", error: NSError(domain: "Please login", code: 1, userInfo: nil))
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
