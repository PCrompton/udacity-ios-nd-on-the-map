//
//  MapTabBarController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

class MapTabBarController: UITabBarController {
    
    var loginSession: UdacityClient.LoginSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if loginSession == nil {
            presentLoginVC()
        }
        ParseClient.StudentInformation.fetchStudents() {
            self.updateChildren()
        }
     }
    
    func updateChildren() {
        for child in childViewControllers {
            if let child = child as? LocationsMapViewController {
                child.loadStudents()
            } else if let child = child as? LocationsTableViewController {
                child.loadStudents()
            }
        }
    }
    
    func presentLoginVC() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.mapTabBarController = self
        present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        loginSession = nil
        presentLoginVC()
    }

    @IBAction func pinButton(_ sender: AnyObject) {
        let infoPostingVC = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        infoPostingVC.loginSession = loginSession
        present(infoPostingVC, animated: true, completion: nil)
    }
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        updateChildren()
    }
}
