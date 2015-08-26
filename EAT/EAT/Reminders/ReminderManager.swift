//
//  ReminderManager.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/19/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class ReminderManager: NSFetchedResultsControllerDelegate {
    class var sharedInstance: ReminderManager {
        struct Static {
            static let instance: ReminderManager = ReminderManager()
        }
        
        return Static.instance
    }
    
    var fetchedResultsController: NSFetchedResultsController?
    
    private func notificationForReminder(reminder: Reminder) -> UILocalNotification {
        let notification = UILocalNotification()
        
        notification.fireDate = reminder.nextDate
        notification.repeatInterval = .CalendarUnitDay
        notification.alertBody = NSLocalizedString("Would you like to rate your appetite?", comment: "reminder alert body")
        notification.alertAction = NSLocalizedString("Rate", comment: "reminder action")
        
        return notification
    }
    
    private func updateLocalNotificationRegistrations() {
        let application = UIApplication.sharedApplication()
        
        if let fetchedObjects = fetchedResultsController?.fetchedObjects as? [Reminder] {
            application.cancelAllLocalNotifications()
            
            if fetchedObjects.count > 0 {
                application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: nil))
            }
            
            for reminder in fetchedObjects {
                application.scheduleLocalNotification(notificationForReminder(reminder))
            }
        }
    }
    
    func start() {
        fetchedResultsController = DataManager.sharedInstance.remindersFetchedResultsController()
        
        var error: NSError?
        
        if fetchedResultsController?.performFetch(&error) == false {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorPerformingFetchRequestNotification, object: error)
        }
        else {
            fetchedResultsController?.delegate = self
            updateLocalNotificationRegistrations()
        }
    }
    
    func stop() {
        fetchedResultsController?.delegate = nil
        fetchedResultsController = nil
    }
    
    func processNotification(notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(ReminderShouldRateActionNotification, object: self)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        updateLocalNotificationRegistrations()
    }
}
