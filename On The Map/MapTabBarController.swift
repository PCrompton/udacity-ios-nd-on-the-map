//
//  MapTabBarController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

protocol MapTabBarControllerChild {
    func loadStudents();
}

class MapTabBarController: UITabBarController {
    
    let parseClient = ParseClient.sharedInstance()
    
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
        fetchStudentsAndUpdate()
     }
    
    func fetchStudentsAndUpdate() {
        parseClient.fetchStudents() {(error) in
            performUpdatesOnMain {
                if let error = error {
                    self.presentError(title: "Failed to Download", errorMessage: error.debugDescription)
                }
                else {
                    for child in self.children {
                        child.loadStudents()
                    }
                }
            }
        }
    }
    
    func presentLoginVC() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.mapTabBarController = self
        present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        UdacityClient.LoginSession.currentLoginSession = nil
        dismiss(animated: true, completion: nil)
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
