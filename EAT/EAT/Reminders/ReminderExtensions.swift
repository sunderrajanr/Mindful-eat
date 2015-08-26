//
//  ReminderExtensions.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/19/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import Foundation

extension Reminder {
    var dateComponents: NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
        
        return dateComponents
    }
    
    func dateAfter(date: NSDate) -> NSDate {
        return NSCalendar.currentCalendar().nextDateAfterDate(date, matchingComponents: dateComponents, options: .MatchNextTime)!
    }
    
    var nextDate: NSDate {
        return dateAfter(NSDate())
    }
}
