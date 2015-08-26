//
//  EATAverageRatingController.m
//  EAT
//
//  Created by Emlyn Murphy on 5/15/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATAverageRatingController.h"
#import "EATMeal.h"
#import <CoreData/CoreData.h>


double const EATAveragesStarvingHungryBoundaryBefore = 4.0;
double const EATAveragesHungryGoodBoundaryBefore = 2.5;
double const EATAveragesGoodFullBoundaryBefore = 0.0;

double const EATAveragesStuffHungryBoundaryAfter = 0.0;
double const EATAveragesGoodBoundaryAfter = 4.0;
double const EATAveragesFullBoundaryAfter = 5.5;
double const EATAveragesStuffedBoundaryAfter = 6.5;


@interface EATAverageRatingController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, assign, readwrite) NSUInteger hungryCountBefore;
@property (nonatomic, assign, readwrite) NSUInteger goodCountBefore;
@property (nonatomic, assign, readwrite) NSUInteger fullCountBefore;


@property (nonatomic, assign, readwrite) NSUInteger hungryCountAfter;
@property (nonatomic, assign, readwrite) NSUInteger goodCountAfter;
@property (nonatomic, assign, readwrite) NSUInteger fullCountAfter;
@property (nonatomic, assign, readwrite) NSUInteger stuffedCountAfter;

@property BOOL isWeek;
@property BOOL isBefore;

@end

@implementation EATAverageRatingController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context isWeek:(BOOL)isWeek isBefore:(BOOL)isBefore
{
    self = [super init];
    
    if (self)
	{
        _context = context;
		_isBefore = isBefore;
		_isWeek = isWeek;
        [self configureCoreData];
    }
    
    return self;
}

- (void)configureCoreData
{
    if ([NSThread isMainThread] == NO)
	{
        [self configureCoreData];
        return;
    }
	
	self.predicate =  [NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [EATMeal class]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EATMeal"];
    NSError *error = nil;
	[fetchRequest setPredicate:[self PredicateForDays]];
    NSArray *meals = [self.context executeFetchRequest:fetchRequest error:&error];
    if (meals == nil)
	{
        NSLog(@"Error fetching: %@, %@", error, error.userInfo);
    }
    
    for (EATMeal *meal in meals)
	{
			[self addValueBefore:[meal.ratingBefore doubleValue]];
			[self addValueAfter:[meal.ratingAfter doubleValue]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextWillSave:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:self.context];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.context];
}


- (NSPredicate *)PredicateForDays
{
	NSCalendar *calender = [NSCalendar currentCalendar];
	NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
	NSDate *startDate = [calender dateFromComponents:currentDateComponents];
	NSDateComponents *sevenDay = [[NSDateComponents alloc] init];
	
	if (_isWeek)
	{
		sevenDay.day = -6;
	}
	else
	{
		sevenDay.day = - 6*7 ;
	}
	
//	sevenDay.day = -6;
	
	NSDate *endDate = [calender dateByAddingComponents:sevenDay toDate:startDate options:0];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@)",endDate];
	return predicate;
	
	
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextWillSave:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(averageValuesWillChange)])
	{
        [self.delegate averageValuesWillChange];
    }
    
    for (EATMeal *meal in self.context.updatedObjects)
	{
        [self removeValueBefore:[meal.ratingBefore doubleValue]];
        [self removeValueAfter:[meal.ratingAfter doubleValue]];
    }
}

- (void)contextDidSave:(NSNotification *)notification
{
    NSSet *insertedObjects = [notification.userInfo[NSInsertedObjectsKey] filteredSetUsingPredicate:self.predicate];
    NSSet *deletedObjects  = [notification.userInfo[NSDeletedObjectsKey] filteredSetUsingPredicate:self.predicate];
    NSSet *updatedObjects  = [notification.userInfo[NSUpdatedObjectsKey] filteredSetUsingPredicate:self.predicate];
    
    for (EATMeal *meal in insertedObjects)
	{
        [self addValueBefore:[meal.ratingBefore doubleValue]];
        [self addValueAfter:[meal.ratingAfter doubleValue]];
    }
    
    for (EATMeal *meal in deletedObjects)
	{
        [self removeValueBefore:[meal.ratingBefore doubleValue]];
        [self removeValueAfter:[meal.ratingAfter doubleValue]];
    }
    
    for (EATMeal *meal in updatedObjects)
	{
        [self addValueBefore:[meal.ratingBefore doubleValue]];
        [self addValueAfter:[meal.ratingAfter doubleValue]];
    }
    
    if ([self.delegate respondsToSelector:@selector(averageValuesDidChange)])
	{
        [self.delegate averageValuesDidChange];
    }
}

#pragma mark - Calculating Values


- (void)addValueBefore:(double)value
{
	
	if (self.hungryCountBefore < NSUIntegerMax && value > EATAveragesStarvingHungryBoundaryBefore)
	{
		self.hungryCountBefore++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeHungryBefore];
		}
	}
	else if (self.goodCountBefore < NSUIntegerMax && value >= EATAveragesHungryGoodBoundaryBefore)
	{
		self.goodCountBefore++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
			[self.delegate averageValueChangedForType:EATAveragesTypeGoodBefore];
		}
	}
	else if (self.fullCountBefore < NSUIntegerMax)
	{
		self.fullCountBefore++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
			[self.delegate averageValueChangedForType:EATAveragesTypeFullBefore];
		}
	}
}

- (void)addValueAfter:(double)value
{
	
	if (self.stuffedCountAfter < NSUIntegerMax && value > EATAveragesStuffedBoundaryAfter)
	{
		self.stuffedCountAfter++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeStuffedAfter];
		}
	}
	else if (self.fullCountAfter < NSUIntegerMax && value >= EATAveragesTypeFullAfter)
	{
		self.fullCountAfter++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeFullAfter];
		}
	}
	else if (self.goodCountAfter < NSUIntegerMax && value >= EATAveragesGoodBoundaryAfter)
	{
		self.goodCountAfter++;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeGoodAfter];
		}
	}
	else if (self.hungryCountAfter < NSUIntegerMax)
	{
		self.hungryCountAfter++;
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeHungryAfter];
		}
	}
}


- (void)removeValueBefore:(double)value
{
    if (self.hungryCountBefore > 0 && value > EATAveragesStarvingHungryBoundaryBefore)
	{
        self.hungryCountBefore--;
		
        if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
            [self.delegate averageValueChangedForType:EATAveragesTypeHungryBefore];
        }
    }
    else if (self.goodCountBefore > 0 && value >= EATAveragesHungryGoodBoundaryBefore && value <  EATAveragesStarvingHungryBoundaryBefore)
	{
        self.goodCountBefore--;
        
        if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
            [self.delegate averageValueChangedForType:EATAveragesTypeGoodBefore];
        }
    }
    else if (self.fullCountBefore > 0 )
	{
        self.fullCountBefore--;
        
        if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
            [self.delegate averageValueChangedForType:EATAveragesTypeFullBefore];
        }
    }
}


- (void)removeValueAfter:(double)value
{
	if (self.stuffedCountAfter > 0 && value > EATAveragesStuffedBoundaryAfter)
	{
		self.stuffedCountAfter--;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
			[self.delegate averageValueChangedForType:EATAveragesTypeStuffedAfter];
		}
	}
	else if (self.fullCountAfter > 0 && value >= EATAveragesFullBoundaryAfter && value <  EATAveragesStuffedBoundaryAfter)
	{
		self.fullCountAfter--;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeFullAfter];
		}
	}
	else if (self.goodCountAfter > 0 && value >= EATAveragesGoodBoundaryAfter && value <  EATAveragesFullBoundaryAfter)
	{
		self.goodCountAfter--;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)])
		{
			[self.delegate averageValueChangedForType:EATAveragesTypeGoodAfter];
		}
	}
	else if (self.hungryCountAfter > 0 )
	{
		self.hungryCountAfter--;
		
		if ([self.delegate respondsToSelector:@selector(averageValueChangedForType:)]) {
			[self.delegate averageValueChangedForType:EATAveragesTypeHungryAfter];
		}
	}
}



@end
