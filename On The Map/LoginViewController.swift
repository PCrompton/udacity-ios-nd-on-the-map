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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var mapTabBarController: MapTabBarController?
    
    var viewDisplaced = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
//        //Test Only
        emailTextField.text = "beethoven89.paul@gmail.com"
        passwordTextField.text = "ew4QyBU#eWET6BOEnpqDroDMj9gkfsa&"
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //Test Only
        //loginButton()
    }
    
    @IBAction func loginButton() {
        activityIndicator.startAnimating()
        guard let username = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        UdacityClient.HTTPBody(username: username, password: password).login() {
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signUpButton(_ sender: AnyObject) {
    }

    // MARK: Keyboard Functions
    override func keyboardWillShow(_ notification: Notification) {
        if !viewDisplaced {
            super.keyboardWillShow(notification)
            viewDisplaced = true
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
        viewDisplaced = false
    }
    
}

