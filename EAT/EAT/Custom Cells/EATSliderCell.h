//
//  EATSliderCell.h
//  EAT
//
//  Created by Emlyn Murphy on 1/27/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EATRatingSlider;

@interface EATSliderCell : UITableViewCell

@property (nonatomic, weak) IBOutlet EATRatingSlider *ratingSlider;

@end
