//
//  MapTabBarController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

class MapTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        StudentInformation.fetchStudents() {
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
    
    @IBAction func logoutButton(_ sender: AnyObject) {
    }

    @IBAction func pinButton(_ sender: AnyObject) {
    }
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        updateChildren()
    }
}
