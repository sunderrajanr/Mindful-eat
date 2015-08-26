//
//  ScaledPhotoExtension.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/8/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class ScaledPhotoFetchRequest: NSFetchRequest {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    convenience init(uuid: String, size: PhotoSize, inManagedObjectContext context: NSManagedObjectContext) {
        self.init()
        entity = NSEntityDescription.entityForName("ScaledPhoto", inManagedObjectContext: context)
        predicate = NSPredicate(format: "uuid = %@ AND width = %i AND height = %i", uuid, size.0, size.1)
    }
}
