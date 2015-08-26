//
//  NSDate+Utils.h
//  EAT
//
//  Created by Emlyn Murphy on 2/1/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (BOOL)isToday;
- (NSDate *)withoutTime;
- (NSString *)humanString;

@end
