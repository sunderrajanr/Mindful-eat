//
//  EATSurveyRoutingCell.m
//  EAT
//
//  Created by Emlyn Murphy on 2/2/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATSurveyRoutingCell.h"

@implementation EATSurveyRoutingCell

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSurveyPositive:(NSNumber *)surveyPositive
{
    _surveyPositive = surveyPositive;
    
    [self updateAppearance];
}

- (void)updateAppearance
{
    [self.positiveButton setImage:[UIImage imageNamed:@"SunLarge"] forState:UIControlStateNormal];
    [self.negativeButton setImage:[UIImage imageNamed:@"CloudLarge"] forState:UIControlStateNormal];
	[self.neturalButton setImage:[UIImage imageNamed:@"RainCloud"] forState:UIControlStateNormal];
	
    if (self.surveyPositive != nil)
	{
        if ([self.surveyPositive isEqualToNumber:@(1)])
		{
            [self.positiveButton setImage:[UIImage imageNamed:@"SunLargeActive"] forState:UIControlStateNormal];
        }
        else if ([self.surveyPositive isEqualToNumber:@(0)])
		{
            [self.negativeButton setImage:[UIImage imageNamed:@"CloudLargeActive"] forState:UIControlStateNormal];
        }
		else
		{
			[self.neturalButton setImage:[UIImage imageNamed:@"RainCloudActive"] forState:UIControlStateNormal];
		}
    }
}

@end
