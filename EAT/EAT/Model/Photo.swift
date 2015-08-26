//
//  EAT.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/8/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var uuid: String
    @NSManaged var meal: EATMeal
    @NSManaged var width: Int32
    @NSManaged var height: Int32

}
