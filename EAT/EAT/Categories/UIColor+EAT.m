//
//  UIColor+EAT.m
//  EAT
//
//  Created by Emlyn Murphy on 1/30/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "UIColor+EAT.h"

@implementation UIColor (EAT)

+ (UIColor *)darkEATColor {
    static UIColor *color = nil;
    
    if (color == nil) {
        color = [UIColor colorWithRed:255 / 255.0
                                green:182 / 255.0
                                 blue:14  / 255.0
                                alpha:1.0];
    }
    
    return color;
}

+ (UIColor *)mediumEATColor {
    static UIColor *color = nil;
    
    if (color == nil) {
        color = [UIColor colorWithRed:249 / 255.0
                                green:236 / 255.0
                                 blue:192 / 255.0
                                alpha:1.0];
    }
    
    return color;
}

+ (UIColor *)lightEATColor {
    static UIColor *color = nil;
    
    if (color == nil) {
        color = [UIColor colorWithRed:255 / 255.0
                                green:131 / 255.0
                                 blue:15  / 255.0
                                alpha:1.0];
    }
    
    return color;
}

@end
