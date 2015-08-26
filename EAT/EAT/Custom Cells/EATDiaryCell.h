//
//  EATDiaryCell.h
//  EAT
//
//  Created by Emlyn Murphy on 2/11/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAT-Swift.h"

@class EATRatingSlider;
@class EATCollapsibleImageView;

@interface EATDiaryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *mealTypeLabel;
@property (nonatomic, weak) IBOutlet EATRatingSlider *ratingSlider;
@property (nonatomic, weak) IBOutlet CollapsibleImageView *drinkCollapsibleImageView;
@property (nonatomic, weak) IBOutlet CollapsibleImageView *sunCollapsibleImageView;
@property (nonatomic, weak) IBOutlet CollapsibleImageView *cloudCollapsibleImageView;
@property (weak, nonatomic) IBOutlet CollapsibleImageView *rainCloudCollapsibleImageView;

@end
