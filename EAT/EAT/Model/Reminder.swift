//
//  Reminder.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/14/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var hour: Int32
    @NSManaged var minute: Int32

}
