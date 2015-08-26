//
//  RemindersMasterViewController.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/6/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class RemindersMasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var fetchedResultsController: NSFetchedResultsController?
    private var reminderToEdit: Reminder?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fetchedResultsController = DataManager.sharedInstance.remindersFetchedResultsController()
        fetchedResultsController?.delegate = self
        
        var error: NSError?
        
        if fetchedResultsController?.performFetch(&error) == false {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorPerformingFetchRequestNotification, object: error)
        }
    }
    
    func configureCell(cell: ReminderCell, atIndexPath indexPath: NSIndexPath) {
        if let fetchedResultsController = fetchedResultsController {
            cell.reminder = fetchedResultsController.objectAtIndexPath(indexPath) as? Reminder
        }
    }
    
    @IBAction func createReminder(sender: AnyObject?) {
        let components = NSCalendar.currentCalendar().components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: NSDate())
        self.reminderToEdit = DataManager.sharedInstance.createReminderForHour(Int32(components.hour), minute: Int32(components.minute))
        self.performSegueWithIdentifier("Edit", sender: sender)
    }
    
    @IBAction func unwindEditing(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? RemindersDetailViewController {
            detailViewController.reminder = reminderToEdit
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        reminderToEdit = fetchedResultsController?.objectAtIndexPath(indexPath) as? Reminder
        performSegueWithIdentifier("Edit", sender: nil)
        return nil
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Reminder") as! ReminderCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! ReminderCell, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
