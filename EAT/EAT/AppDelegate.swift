//
//  AppDelegate.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/5/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Crashlytics.startWithAPIKey("5f1616815586550986a942ec1817e03f5a0d4faa")
        customizeAppearance()
        return true
    }
    
    func customizeAppearance() {
        window?.tintColor = UIColor.orangeColor()
        UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        UISwitch.appearance().onTintColor = UIColor.orangeColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        ReminderManager.sharedInstance.processNotification(notification)
    }
}
