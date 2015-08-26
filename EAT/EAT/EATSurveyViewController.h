//
//  EATSurveyViewController.h
//  EAT
//
//  Created by Emlyn Murphy on 2/1/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class EATMeal;

@interface EATSurveyViewController : UITableViewController

@property (nonatomic, strong) EATMeal *meal;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *doneButtonTitle;

@end
