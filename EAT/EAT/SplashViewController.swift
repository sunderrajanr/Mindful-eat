//
//  SplashViewController.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/31/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {
        PersistenceManager.sharedInstance.dispatchWhenInitialized {
            ReminderManager.sharedInstance.start()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if defaults.objectForKey("CompletedOnboarding")?.boolValue == true {
                self.performSegueWithIdentifier("SkipOnboarding", sender: self)
            }
            else {
                self.performSegueWithIdentifier("Onboarding", sender: self)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
