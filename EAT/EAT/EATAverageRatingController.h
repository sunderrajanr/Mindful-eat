//
//  EATAverageRatingController.h
//  EAT
//
//  Created by Emlyn Murphy on 5/15/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

@import CoreData;

typedef NS_ENUM(NSUInteger, EATAveragesType)
{
	EATAveragesTypeHungryBefore,
	EATAveragesTypeGoodBefore,
	EATAveragesTypeFullBefore,
	
    EATAveragesTypeHungryAfter,
    EATAveragesTypeGoodAfter,
    EATAveragesTypeFullAfter,
    EATAveragesTypeStuffedAfter
};


FOUNDATION_EXPORT double const EATAveragesStarvingHungryBoundaryBefore;
FOUNDATION_EXPORT double const EATAveragesHungryGoodBoundaryBefore;
FOUNDATION_EXPORT double const EATAveragesGoodFullBoundaryBefore;

FOUNDATION_EXPORT double const EATAveragesStuffHungryBoundaryAfter;
FOUNDATION_EXPORT double const EATAveragesGoodBoundaryAfter;
FOUNDATION_EXPORT double const EATAveragesFullBoundaryAfter;
FOUNDATION_EXPORT double const EATAveragesStuffedBoundaryAfter;

@protocol EATAveragesDelegate <NSObject>

@optional

- (void)averageValueChangedForType:(EATAveragesType)type;
- (void)averageValuesWillChange;
- (void)averageValuesDidChange;

@end

@interface EATAverageRatingController : NSObject

@property (nonatomic, weak) id<EATAveragesDelegate> delegate;

//@property (nonatomic, assign, readonly) NSUInteger starvingCountAfter;
@property (nonatomic, assign, readonly) NSUInteger hungryCountAfter;
@property (nonatomic, assign, readonly) NSUInteger goodCountAfter;
@property (nonatomic, assign, readonly) NSUInteger fullCountAfter;
@property (nonatomic, assign, readonly) NSUInteger stuffedCountAfter;

@property (nonatomic, assign, readonly) NSUInteger hungryCountBefore;
@property (nonatomic, assign, readonly) NSUInteger goodCountBefore;
@property (nonatomic, assign, readonly) NSUInteger fullCountBefore;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context isWeek:(BOOL)isWeek isBefore:(BOOL)isBefore;

@end
