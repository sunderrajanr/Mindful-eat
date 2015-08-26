//
//  AppRouteManager.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/15/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class AppRouteManager: NSObject, MainTabBarControllerRouteManagement, DiaryViewControllerRouteManagement, RatingViewControllerRouteManagement {
    class var sharedInstance: AppRouteManager {
        struct Static {
            static let instance: AppRouteManager = AppRouteManager()
        }
        
        return Static.instance
    }
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderShouldRateAction:", name: ReminderShouldRateActionNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    weak var mainTabBarController: MainTabBarController?
    weak var diaryViewController: EATDiaryViewController?
    weak var ratingViewController: EATRatingViewController?
    
    func reminderShouldRateAction(notification: NSNotification) {
        // Start a new rating only if the rating view controller isn't already open.
        if ratingViewController == nil {
            mainTabBarController?.selectedIndex = 0
            diaryViewController?.addMeal(self)
        }
    }
}
