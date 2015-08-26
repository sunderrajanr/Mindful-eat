//
//  EATRatingHistoryController.m
//  EAT
//
//  Created by Emlyn Murphy on 5/31/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATRatingHistoryController.h"
#import "Model/EATMeal.h"
#import "NSDate+Utils.h"

@interface EATRatingHistoryController ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSMutableDictionary *mealsByDate;
@property (nonatomic, strong) NSMutableArray *orderedMeals;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSArray *scaledIndices;
@end

@implementation EATRatingHistoryController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    
    if (self)
	{
        _context = context;
        _mealsByDate = [NSMutableDictionary new];
        _orderedMeals = [NSMutableArray new];
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        [self configureCoreData];
    }
    
    return self;
}


- (NSUInteger)totalDays
{
    if (self.orderedMeals.count == 0) {
        return 0;
    }
    
    NSDate *firstDate = [((EATMeal *)[self.orderedMeals firstObject]).date withoutTime];
    NSDate *lastDate  = [((EATMeal *)[self.orderedMeals lastObject]).date withoutTime];
	
	
    NSTimeInterval totalInterval = [lastDate timeIntervalSinceDate:firstDate];
    
    return lround(totalInterval / 86400) + 1;
}

- (NSUInteger)mealCount
{
    return self.orderedMeals.count;
}

- (EATMeal *)mealAtIndex:(NSUInteger)index
{
    return self.orderedMeals[index];
}

- (NSNumber *)dayAtIndex:(NSUInteger)index
{
    return self.scaledIndices[index];
}

- (void)configureCoreData
{
    if ([NSThread isMainThread] == NO)
 {
        [self configureCoreData];
        return;
    }

    self.predicate = [NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [EATMeal class]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EATMeal"];
    NSError *error = nil;
    NSArray *meals = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (meals == nil) {
        NSLog(@"Error fetching: %@, %@", error, error.userInfo);
    }
    
    for (EATMeal *meal in meals)
	{
        [self addMeal:meal];
    }
    
    [self calculateScaledIndices];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextWillSave:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:self.context];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.context];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextWillSave:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ratingHistoryWillChange)]) {
        [self.delegate ratingHistoryWillChange];
    }
    
    for (EATMeal *meal in self.context.updatedObjects) {
        [self removeMeal:meal];
    }
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *insertedObjects = [notification.userInfo[NSInsertedObjectsKey] filteredSetUsingPredicate:self.predicate];
    NSSet *deletedObjects  = [notification.userInfo[NSDeletedObjectsKey] filteredSetUsingPredicate:self.predicate];
    NSSet *updatedObjects  = [notification.userInfo[NSUpdatedObjectsKey] filteredSetUsingPredicate:self.predicate];
    
    for (EATMeal *meal in insertedObjects) {
        [self addMeal:meal];
    }
    
    for (EATMeal *meal in deletedObjects) {
        [self removeMeal:meal];
    }
    
    for (EATMeal *meal in updatedObjects) {
        [self addMeal:meal];
    }
    
    if ([self.delegate respondsToSelector:@selector(ratingHistoryDidChange)]) {
        [self.delegate ratingHistoryDidChange];
    }
}

#pragma mark - Calculating Values

- (void)addMeal:(EATMeal *)meal {
    NSDate *date = [meal.date withoutTime];
    
    if (self.mealsByDate[date] == nil) {
        self.mealsByDate[date] = [NSMutableArray new];
    }
    
    [self.mealsByDate[date] addObject:meal];
    [self.mealsByDate[date] sortUsingDescriptors:self.sortDescriptors];
    
    [self.orderedMeals addObject:meal];
    [self.orderedMeals sortUsingDescriptors:self.sortDescriptors];
}

- (void)removeMeal:(EATMeal *)meal {
    NSDate *date = [meal.date withoutTime];
    
    [self.mealsByDate[date] removeObject:meal];
    
    if ([self.mealsByDate[date] count] == 0) {
        [self.mealsByDate removeObjectForKey:date];
    }
    
    [self.orderedMeals removeObject:meal];
}

- (void)calculateScaledIndices {
    NSMutableArray *mutableScaledIndices = [[NSMutableArray alloc] initWithCapacity:self.orderedMeals.count];
    NSDate *firstDate = [((EATMeal *)[self.orderedMeals firstObject]).date withoutTime];

    for (EATMeal *meal in self.orderedMeals) {
        NSDate *date = [meal.date withoutTime];
        NSTimeInterval scaledIndex = [date timeIntervalSinceDate:firstDate] / 86400;
        double index = [self.mealsByDate[date] indexOfObject:meal];
        double total = [self.mealsByDate[date] count];
        
        scaledIndex += index / total;
        
        [mutableScaledIndices addObject:@(scaledIndex)];
    }
    
    self.scaledIndices = [mutableScaledIndices copy];
}

@end
