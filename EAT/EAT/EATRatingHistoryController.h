//
//  EATRatingHistoryController.h
//  EAT
//
//  Created by Emlyn Murphy on 5/31/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EATRatingHistoryControllerDelegate <NSObject>

@optional

- (void)ratingHistoryWillChange;
- (void)ratingHistoryDidChange;

@end


@class EATMeal;

@interface EATRatingHistoryController : NSObject

@property (nonatomic, weak) id<EATRatingHistoryControllerDelegate> delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (NSUInteger)totalDays;
- (NSUInteger)mealCount;
- (EATMeal *)mealAtIndex:(NSUInteger)index;
- (NSNumber *)dayAtIndex:(NSUInteger)index;

@end
