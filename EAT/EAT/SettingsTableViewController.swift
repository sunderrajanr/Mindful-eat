//
//  SettingsTableViewController.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/4/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        parentViewController?.tabBarItem.selectedImage = UIImage(named: "SettingsIconSelected")
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("iCloudSync") as! UITableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("EATOnline") as! UITableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("Reminders") as! UITableViewCell
            return cell
        default:
            fatalError("Requested unknown table row.")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch indexPath.row {
        case 1:
            performSegueWithIdentifier("EATOnline", sender: self)
        case 2:
            performSegueWithIdentifier("Reminders", sender: self)
        default:
            break
        }
        
        return nil
    }
}
