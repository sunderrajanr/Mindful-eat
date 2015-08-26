//
//  ReminderCell.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/14/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    @IBOutlet var timeLabel: UILabel? {
        didSet {
            configureView()
        }
    }
    
    var reminder: Reminder? {
        didSet {
            configureView()
        }
    }
    
    private func configureView() {
        timeLabel?.text = formattedTime()
    }
    
    private func dateWithHour(hour: Int32, minute: Int32) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    }
    
    private func formattedTime() -> String {
        if let reminder = reminder {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            return dateFormatter.stringFromDate(dateWithHour(reminder.hour, minute: reminder.minute))
        }
        
        return ""
    }
}
