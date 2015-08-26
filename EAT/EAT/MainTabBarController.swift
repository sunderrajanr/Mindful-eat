//
//  MainTabBarController.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/15/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        AppRouteManager.sharedInstance.mainTabBarController = self
    }
}
