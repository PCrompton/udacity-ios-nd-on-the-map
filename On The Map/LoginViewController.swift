//
//  LoginViewController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var mapTabBarController: MapTabBarController? = nil
    var loginSession: UdacityClient.LoginSession? {
        didSet {
            if let mapTabBarController = mapTabBarController {
                mapTabBarController.loginSession = loginSession
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test Only
        emailTextField.text = "john.doe89@gmail.com"
        passwordTextField.text = "password"
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //Test Only
        loginButton()
    }
    
    @IBAction func loginButton() {
        
        guard let username = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        UdacityClient.HTTPBody(username: username, password: password).login(sender: self) { () in
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signUpButton(_ sender: AnyObject) {
    }

}

