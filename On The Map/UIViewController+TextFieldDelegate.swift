//
//  UIViewController+TextFieldDelegate.swift
//  On The Map
//
//  Created by Paul Crompton on 10/7/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: UITextFieldDelegate {
    
    // MARK textFieldDelegate functions
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        unsubscribeToKeyboardNotifications()
    }

}
