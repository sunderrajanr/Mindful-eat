//
//  EATSurveyRoutingCell.h
//  EAT
//
//  Created by Emlyn Murphy on 2/2/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EATSurveyRoutingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *positiveButton;
@property (nonatomic, weak) IBOutlet UIButton *negativeButton;
@property (weak, nonatomic) IBOutlet UIButton *neturalButton;
@property (nonatomic, strong) NSNumber *surveyPositive;

@end
