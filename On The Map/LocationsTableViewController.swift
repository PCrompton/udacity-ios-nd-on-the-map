//
//  LocationsTableViewController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UITableViewController, MapTabBarControllerChild {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudents()
    }

    func loadStudents() {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = StudentInformation.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInformationCell", for: indexPath)
        
        let firstName: String
        if let name = student.firstName {
            firstName = name
        } else {
            firstName = ""
        }
        let lastName: String
        if let name = student.lastName {
            lastName = name
        } else {
            lastName = ""
        }
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
        if let mediaURLString = student.mediaURLString {
            cell.detailTextLabel?.text = mediaURLString
        } else {
            cell.detailTextLabel?.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInformation.students[indexPath.row]
        student.openMediaURL(sender: self)
    }
}
