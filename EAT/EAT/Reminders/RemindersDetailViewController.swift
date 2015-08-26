//
//  RemindersDetailViewController.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/6/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class RemindersDetailViewController: UITableViewController {
    var reminder: Reminder? {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet var datePicker: UIDatePicker? {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet var deleteCell: UITableViewCell?
    
    @IBAction func timeChanged(sender: AnyObject?) {
        if let date = datePicker?.date {
            let components = NSCalendar.currentCalendar().components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: date)
            
            if let reminder = reminder {
                reminder.hour = Int32(components.hour)
                reminder.minute = Int32(components.minute)
            }
        }
    }
    
    override func viewDidLoad() {
        configureView()
    }
    
    func configureView() {
        if let reminder = reminder {
            let dateComponents = NSDateComponents()
            dateComponents.hour = Int(reminder.hour)
            dateComponents.minute = Int(reminder.minute)
            
            if let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents) {
                datePicker?.date = date
            }
        }
    }
    
    private lazy var deleteAlertController: UIAlertController = {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) -> Void in
            self.deleteReminder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.darkTextColor()
        
        return alertController
    }()

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = deleteCell {
            if tableView.cellForRowAtIndexPath(indexPath) == cell {
                presentViewController(deleteAlertController, animated: true, completion: nil)
            }
        }
        
        return nil
    }
    
    private func deleteReminder() {
        if let reminder = reminder {
            DataManager.sharedInstance.deleteObject(reminder)
            performSegueWithIdentifier("done", sender: nil)
        }
    }
}
