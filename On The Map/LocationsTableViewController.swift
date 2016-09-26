//
//  LocationsTableViewController.swift
//  On The Map
//
//  Created by Paul Crompton on 9/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func loadStudents() {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.StudentInformation.students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = ParseClient.StudentInformation.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInformationCell", for: indexPath)
        
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        
        if let url = student.mediaURL {
            cell.detailTextLabel?.text = url.absoluteString
        } else {
            cell.detailTextLabel?.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = ParseClient.StudentInformation.students[indexPath.row]
        student.openMediaURL(sender: self)
    }
}
