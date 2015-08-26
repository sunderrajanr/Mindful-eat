//
//  PersistenceManager.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/7/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit
import CoreData

public let ErrorOpeningMangedObjectContextNotification = "ErrorOpeningMangedObjectContextNotification"
public let ErrorSavingMangedObjectContextNotification = "ErrorSavingMangedObjectContextNotification"
public let ErrorDeletingPersistentStoreNotification = "ErrorDeletingPersistentStoreNotification"
public let ErrorFetchingManagedObjectNotification = "ErrorFetchingManagedObjectNotification"

private let modelURL: NSURL = NSBundle.mainBundle().URLForResource("EAT", withExtension: "momd")!
private let storeName = "EAT.sqlite"

class PersistenceManager: NSObject {
    class var sharedInstance: PersistenceManager {
        struct Static {
            static let instance: PersistenceManager = PersistenceManager()
        }
        
        return Static.instance
    }
    
    private let initSemaphore = dispatch_semaphore_create(0)
    
    var mainContext: NSManagedObjectContext!
    
    private var backgroundIOContext: NSManagedObjectContext!
    private let saveDispatchGroup = dispatch_group_create()
    private let autoSaveDelay = Int64(15 * Double(NSEC_PER_SEC))
    
    private class var storeURL: NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
            inDomains: .UserDomainMask).last!.URLByAppendingPathComponent(storeName)
    }
    
    override init() {
        super.init()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let managedObjectModel: NSManagedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            var error: NSError?
            
            if persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: PersistenceManager.storeURL,
                options: options, error: &error) == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(ErrorOpeningMangedObjectContextNotification,
                        object: error)
            }
            
            self.backgroundIOContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            self.backgroundIOContext.persistentStoreCoordinator = persistentStoreCoordinator
            
            self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            self.mainContext.parentContext = self.backgroundIOContext
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "objectsInMainContextDidChange:",
                name: NSManagedObjectContextObjectsDidChangeNotification, object: self.mainContext)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:",
                name: UIApplicationWillResignActiveNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillTerminate:",
                name: UIApplicationWillTerminateNotification, object: nil)
            
            dispatch_semaphore_signal(self.initSemaphore)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func dispatchWhenInitialized(block: () -> Void) {
        if mainContext != nil {
            block()
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_semaphore_wait(self.initSemaphore, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        }
    }
    
    class func deleteStore() {
        var error: NSError?
        
        if NSFileManager.defaultManager().removeItemAtURL(PersistenceManager.storeURL, error: &error) == false {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorDeletingPersistentStoreNotification, object: error)
        }
    }
    
    private func save() {
        var error: NSError?
        
        mainContext.performBlock {
            if self.mainContext.save(&error) == false {
                NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                    object: error)
            }
            else {
                self.backgroundIOContext.performBlock {
                    if self.backgroundIOContext.save(&error) == false {
                        NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification, object: error)
                    }
                }
            }
        }
    }
    
    func saveContext(context: NSManagedObjectContext) {
        var error: NSError?
        
        if context.save(&error) == false {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                object: error)
        }
    }
    
    func temporaryContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = mainContext
        return context
    }
    
    func temporaryContext(completionBlock: (_: NSManagedObjectContext) -> Bool) {
        let context = temporaryContext()
        
        if NSThread.isMainThread() {
            if completionBlock(context) {
                var error: NSError?
                
                if context.save(&error) == false {
                    NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                        object: error)
                }
            }
        }
        else {
            context.performBlock {
                if completionBlock(context) {
                    var error: NSError?
                    
                    if context.save(&error) == false {
                        NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                            object: error)
                    }
                }
            }
        }
    }
    
    func existingObject(object: NSManagedObject, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        if object.objectID.temporaryID {
            var error: NSError?
            
            if object.managedObjectContext?.obtainPermanentIDsForObjects([object], error: &error) == false {
                NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                    object: error)
                return nil
            }
        }

        var objectInContext: NSManagedObject?
        var error: NSError?
        
        if context.concurrencyType != .MainQueueConcurrencyType {
            context.performBlockAndWait {
                objectInContext = context.existingObjectWithID(object.objectID, error: &error)
            }
        }
        else {
            objectInContext = context.existingObjectWithID(object.objectID, error: &error)
        }

        if objectInContext == nil {
            NSNotificationCenter.defaultCenter().postNotificationName(ErrorFetchingManagedObjectNotification,
                object: error)
        }
        
        return objectInContext
    }
    
    func backgroundContextWithParentContext(parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = parentContext
        return context
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return backgroundContextWithParentContext(mainContext)
    }
    
    func backgroundContextWithParentContext(parentContext: NSManagedObjectContext, completionBlock: (_: NSManagedObjectContext) -> Bool) {
        let context = backgroundContextWithParentContext(parentContext)
        
        context.performBlock {
            if completionBlock(context) {
                var error: NSError?
                
                if context.save(&error) == false {
                    NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                        object: error)
                }
            }
        }
    }
    
    func backgroundContextWithExistingObject(object: NSManagedObject, completionBlock: (_: NSManagedObject) -> Bool) {
        let context = backgroundContextWithParentContext(object.managedObjectContext!)
        let backgroundObject = existingObject(object, inContext: context)
        
        context.performBlock {
            if completionBlock(backgroundObject!) {
                var error: NSError?
                
                if context.save(&error) == false {
                    NSNotificationCenter.defaultCenter().postNotificationName(ErrorSavingMangedObjectContextNotification,
                        object: error)
                }
            }
        }
    }
    
    func backgroundContext(completionBlock: (_: NSManagedObjectContext) -> Bool) {
        fatalError("backgroundContext(completionBlock:) has not been implemented")
    }
    
    // MARK: - Notifications
    
    func objectsInMainContextDidChange(sender: AnyObject?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_group_enter(self.saveDispatchGroup)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.autoSaveDelay),
                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_group_leave(self.saveDispatchGroup)
            })
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_group_wait(self.saveDispatchGroup, DISPATCH_TIME_FOREVER)
                self.save()
            })
        })
    }

    func applicationWillResignActive(sender: AnyObject?) {
        save()
    }
    
    func applicationWillTerminate(sender: AnyObject?) {
        save()
    }
}
