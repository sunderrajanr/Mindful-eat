//
//  NSDate+Utils.m
//  EAT
//
//  Created by Emlyn Murphy on 2/1/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (BOOL)isToday {
    static NSCalendar *calendar = nil;
    
    if (calendar == nil) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSDateComponents *todayComponenets = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
                                                     fromDate:[NSDate new]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
                                                   fromDate:self];
    
    return (todayComponenets.day == dateComponents.day &&
            todayComponenets.month == dateComponents.month &&
            todayComponenets.year == dateComponents.year);
}

- (NSDate *)withoutTime {
    static NSCalendar *calendar = nil;
    
    if (calendar == nil) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay
                                                   fromDate:self];
    
    return [calendar dateFromComponents:dateComponents];
}

- (NSString *)humanString {
	return [self humanStringWithRespectToDate:[NSDate date]];
}

- (NSString *)monthStringForInteger:(NSInteger)month {
	switch (month) {
		case 1:
			return NSLocalizedString(@"Jan", nil);
            
		case 2:
			return NSLocalizedString(@"Feb", nil);
            
		case 3:
			return NSLocalizedString(@"Mar", nil);
            
		case 4:
			return NSLocalizedString(@"Apr", nil);
            
		case 5:
			return NSLocalizedString(@"May", nil);
            
		case 6:
			return NSLocalizedString(@"June", nil);
            
		case 7:
			return NSLocalizedString(@"July", nil);
            
		case 8:
			return NSLocalizedString(@"Aug", nil);
            
		case 9:
			return NSLocalizedString(@"Sept", nil);
            
		case 10:
			return NSLocalizedString(@"Oct", nil);
            
		case 11:
			return NSLocalizedString(@"Nov", nil);
            
		case 12:
			return NSLocalizedString(@"Dec", nil);
            
		default:
			return nil;
	}
}

- (NSString *)humanStringWithRespectToDate:(NSDate *)referenceDate {
	NSUInteger calendarUnits = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitTimeZone | NSCalendarUnitWeekday;
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                   fromDate:self];
    
	NSDateComponents *referenceDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                            fromDate:referenceDate];
    
	if (dateComponents.year == referenceDateComponents.year &&
	    dateComponents.month == referenceDateComponents.month &&
	    dateComponents.day == referenceDateComponents.day) {
		return NSLocalizedString(@"Today", nil);
	}
    
	NSDate *yesterday = [referenceDate dateByAddingTimeInterval:-86400];
	NSDateComponents *yesterdayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                            fromDate:yesterday];
    
	if (dateComponents.year == yesterdayDateComponents.year &&
	    dateComponents.month == yesterdayDateComponents.month &&
	    dateComponents.day == yesterdayDateComponents.day) {
		return NSLocalizedString(@"Yesterday", nil);
	}
    
	NSDate *tomorrow = [referenceDate dateByAddingTimeInterval:86400];
	NSDateComponents *tomorrowDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                           fromDate:tomorrow];
    
	if (dateComponents.year == tomorrowDateComponents.year &&
	    dateComponents.month == tomorrowDateComponents.month &&
	    dateComponents.day == tomorrowDateComponents.day) {
		return NSLocalizedString(@"Tomorrow", nil);
	}
    
	NSDate *sunday = [referenceDate dateByAddingTimeInterval:(1 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *sundayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                         fromDate:sunday];
    
	if (dateComponents.year == sundayDateComponents.year &&
	    dateComponents.month == sundayDateComponents.month &&
	    dateComponents.day == sundayDateComponents.day) {
		return NSLocalizedString(@"Sun", nil);
	}
    
	NSDate *monday = [referenceDate dateByAddingTimeInterval:(2 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *mondayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                         fromDate:monday];
    
	if (dateComponents.year == mondayDateComponents.year &&
	    dateComponents.month == mondayDateComponents.month &&
	    dateComponents.day == mondayDateComponents.day) {
		return NSLocalizedString(@"Mon", nil);
	}
    
	NSDate *tuesday = [referenceDate dateByAddingTimeInterval:(3 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *tuesdayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                          fromDate:tuesday];
    
	if (dateComponents.year == tuesdayDateComponents.year &&
	    dateComponents.month == tuesdayDateComponents.month &&
	    dateComponents.day == tuesdayDateComponents.day) {
		return NSLocalizedString(@"Tue", nil);
	}
    
	NSDate *wednesday = [referenceDate dateByAddingTimeInterval:(4 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *wednesdayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                            fromDate:wednesday];
    
	if (dateComponents.year == wednesdayDateComponents.year &&
	    dateComponents.month == wednesdayDateComponents.month &&
	    dateComponents.day == wednesdayDateComponents.day) {
		return NSLocalizedString(@"Wed", nil);
	}
    
	NSDate *thursday = [referenceDate dateByAddingTimeInterval:(5 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *thursdayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                           fromDate:thursday];
    
	if (dateComponents.year == thursdayDateComponents.year &&
	    dateComponents.month == thursdayDateComponents.month &&
	    dateComponents.day == thursdayDateComponents.day) {
		return NSLocalizedString(@"Thu", nil);
	}
    
	NSDate *friday = [referenceDate dateByAddingTimeInterval:(6 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *fridayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                         fromDate:friday];
    
	if (dateComponents.year == fridayDateComponents.year &&
	    dateComponents.month == fridayDateComponents.month &&
	    dateComponents.day == fridayDateComponents.day) {
		return NSLocalizedString(@"Fri", nil);
	}
    
	NSDate *saturday = [referenceDate dateByAddingTimeInterval:(7 - referenceDateComponents.weekday) * 86400];
	NSDateComponents *saturdayDateComponents = [[NSCalendar currentCalendar] components:calendarUnits
	                                                                           fromDate:saturday];
    
	if (dateComponents.year == saturdayDateComponents.year &&
	    dateComponents.month == saturdayDateComponents.month &&
	    dateComponents.day == saturdayDateComponents.day) {
		return NSLocalizedString(@"Sat", nil);
	}
    
	if (dateComponents.year == referenceDateComponents.year) {
		return [NSString stringWithFormat:NSLocalizedString(@"%@ %i", @"{month} {day}"),
		        [self monthStringForInteger:dateComponents.month], dateComponents.day];
	}
    
	return [NSString stringWithFormat:NSLocalizedString(@"%@ %i, %i", @"{month} {day}, {year}"),
	        [self monthStringForInteger:dateComponents.month], dateComponents.day, dateComponents.year];
}

@end
