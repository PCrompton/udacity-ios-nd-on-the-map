//
//  SuperClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class SuperClient: NSObject {
    // MARK: Properties
    var session = URLSession.shared
    //var config = ParseConfig()
    
    override init() {
        super.init()
    }
}
