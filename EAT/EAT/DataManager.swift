//
//  DataManager.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/8/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import CoreData

public let ErrorPerformingFetchRequestNotification = "ErrorPerformingFetchRequestNotification"
public let ErrorObtainingPermanentObjectIDs = "ErrorObtainingPermanentObjectIDs"

class DataManager: NSObject {
    class var sharedInstance: DataManager
	{
        struct Static {
            static let instance: DataManager = DataManager()
        }
        
        return Static.instance
    }

    override init()
	{
        super.init()
    }
    
    func deleteObject(object: NSManagedObject)
	{
        object.managedObjectContext?.deleteObject(object)
    }
    
	func averageRatingController(isWeek:Bool,isBefore:Bool) -> EATAverageRatingController
	{
		return EATAverageRatingController(managedObjectContext: PersistenceManager.sharedInstance.mainContext,isWeek: isWeek,isBefore: isBefore);
    }
    
    func ratingHistoryController() -> EATRatingHistoryController
	{
        return EATRatingHistoryController(managedObjectContext: PersistenceManager.sharedInstance.mainContext)
    }

    private func nextSortValueForDate(date: NSDate, inContext context: NSManagedObjectContext) -> Int
	{
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("EATMeal", inManagedObjectContext: context)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicateForDate(date)
        
        var error: NSError?
        
        if let meals = context.executeFetchRequest(fetchRequest, error: &error) {
            if let lastMeal = meals.first as? EATMeal {
                return lastMeal.sortOrder.integerValue + 1
            }
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorPerformingFetchRequestNotification,
                object: error)
        }
        
        return 0
    }
    
    func createMealForDate(date: NSDate, inManagedObjectContext context: NSManagedObjectContext) -> EATMeal?
	{
        let meal = NSEntityDescription.insertNewObjectForEntityForName("EATMeal",
            inManagedObjectContext: context) as! EATMeal
        meal.date = date
        meal.sortOrder = nextSortValueForDate(date, inContext: context)
        meal.snack = false
		
        return meal
    }
    
    func createReminderForHour(hour: Int32, minute: Int32) -> Reminder? {
        let reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder",
            inManagedObjectContext: PersistenceManager.sharedInstance.mainContext) as! Reminder
        reminder.hour = hour
        reminder.minute = minute
        return reminder
    }
    
    private func predicateForDate(date: NSDate) -> NSPredicate
	{
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit,
            fromDate: date)
        let startDate = calendar.dateFromComponents(currentDateComponents)!
        
        let oneDay = NSDateComponents()
        oneDay.day = 1
        
        let endDate = calendar.dateByAddingComponents(oneDay, toDate: startDate, options: .allZeros)!
         return NSPredicate(format: "date >= %@ AND date < %@", startDate, endDate)
    }

    func mealsFetchedResultsControllerForDate(date: NSDate) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "EATMeal")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        fetchRequest.predicate = predicateForDate(date)
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceManager.sharedInstance.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func remindersFetchedResultsController() -> NSFetchedResultsController
	{
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hour", ascending: true), NSSortDescriptor(key: "minute", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceManager.sharedInstance.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
	
	func getAllLessons() -> NSFetchedResultsController
	{
		let fetchRequest = NSFetchRequest(entityName: "EATMeal")
//		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: false),NSSortDescriptor(key: "date", ascending: false)]
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		
		var predicatesurveyPositiveComment = NSPredicate(format: "surveyPositiveComment!=nil AND surveyPositiveComment!=''")
		var predicatesurveyNegativeComment = NSPredicate(format: "surveyNegativeComment!=nil AND surveyNegativeComment!=''")
		var predicatesurveyNeturalComment = NSPredicate(format: "surveyNeturalComment!=nil AND surveyNeturalComment!=''")
		
		fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicatesurveyPositiveComment,predicatesurveyNegativeComment,predicatesurveyNeturalComment])
		
		
		return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceManager.sharedInstance.mainContext, sectionNameKeyPath: nil, cacheName: nil)

	}
}
