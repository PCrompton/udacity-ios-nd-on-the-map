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
    }
    
    @IBAction func loginButton() {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let username = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        guard username != "" else {
            presentError(title: "No Email Entered", errorMessage: "Please enter a valid email addres in the Email field")
            return
        }
        guard password != "" else {
            presentError(title: "No Password Entered", errorMessage: "Please enter a valid password in the password field")
            return
        }
        activityIndicator.startAnimating()
        UdacityClient.login(with: username, password: password) {(errorMessage) in
            self.activityIndicator.stopAnimating()
            if let errorMessage = errorMessage {
                self.presentError(title: "Error Logging In", errorMessage: errorMessage)
            }
            else {
                self.mapTabBarController?.fetchStudentsAndUpdate()
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }

    @IBAction func signUpButton(_ sender: AnyObject) {
        let url = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated&_ga=1.124035849.286073158.1467132567")!
        UIApplication.shared.open(url, options: [:])
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

