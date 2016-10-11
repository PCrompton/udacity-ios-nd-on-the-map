//
//  MapTabBarController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

protocol MapTabBarControllerChild {
    func startActivityIndicator();
    func stopActivityIndicator();
    func loadStudents();
    
}

class MapTabBarController: UITabBarController {
    
    var children: [MapTabBarControllerChild] {
        get {
            var children = [MapTabBarControllerChild]()
            for child in childViewControllers {
                if let child = child as? MapTabBarControllerChild {
                    children.append(child)
                }
            }
            return children
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UdacityClient.LoginSession.currentLoginSession == nil {
            presentLoginVC()
        }
        else {
            fetchStudentsAndUpdate()
        }
     }
    
    func fetchStudentsAndUpdate() {
        for child in children {
            child.startActivityIndicator()
        }
        ParseClient.StudentInformation.fetchStudents() {(error) in
            performUpdatesOnMain {
                if let error = error {
                    self.presentNetworkError(title: "Failed to Download", error: error)
                } else {
                    self.updateChildren()
                }
            }
        }
        for child in children {
            child.stopActivityIndicator()
        }
    }
    
    func updateChildren() {
        for child in children {
            child.loadStudents()
        }
    }
    
    func presentLoginVC() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.mapTabBarController = self
        present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        UdacityClient.LoginSession.currentLoginSession = nil
        presentLoginVC()
    }

    @IBAction func pinButton(_ sender: AnyObject) {
        let infoPostingVC = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        infoPostingVC.mapTabBarController = self
        present(infoPostingVC, animated: true, completion: nil)
    }
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        fetchStudentsAndUpdate()
    }
}
