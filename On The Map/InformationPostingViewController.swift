//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    var loginSession: UdacityClient.LoginSession? = nil
    
    @IBOutlet weak var userName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loginSession = loginSession {
            userName.text = "\(loginSession.user.firstName) \(loginSession.user.lastName)"
        }
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitButton(_ sender: AnyObject) {
    }

}
