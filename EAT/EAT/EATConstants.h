//
//  EATConstants.h
//  EAT
//
//  Created by Emlyn Murphy on 5/17/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define EATRedColor    UIColorFromRGB(0xff0000)
#define EATYellowColor UIColor.orangeColor
#define EATGreenColor  UIColorFromRGB(0x73bc05)
