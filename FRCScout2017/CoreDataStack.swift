//
//  CoreDataStack.swift
//  FRCScout2017
//
//  Created by Sharon Kass on 2/20/17.
//  Copyright © 2017 RoboTigers. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class CoreDataStack: NSObject, CDEPersistentStoreEnsembleDelegate {
    
    static let defaultStack = CoreDataStack()
    
    var ensemble : CDEPersistentStoreEnsemble? = nil
    var cloudFileSystem : CDEICloudFileSystem? = nil
    
    // MARK: - Core Data stack
    
    lazy var storeName : String = {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }()
    
    lazy var sqlName : String = {
        return self.storeName + ".sqlite"
    }()
    
    lazy var icloudStoreName : String = {
        return self.storeName + "CloudStore"
    }()
    
    lazy var storeDescription : String = {
        return "Core data stack of " + self.storeName
    }()
    
    lazy var iCloudAppID : String = {
        return "iCloud." + Bundle.main.bundleIdentifier!
    }()
    
    lazy var modelURL : URL = {
        return Bundle.main.url(forResource: self.storeName, withExtension: "momd")!
    }()
    
    lazy var storeDirectoryURL : URL = {
        var directoryURL : URL? = nil
        do {
            try directoryURL = FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            directoryURL = directoryURL!.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
        } catch {
            NSLog("Unresolved error: Application's document directory is unreachable")
            abort()
        }
        return directoryURL!
    }()
    
    lazy var storeURL : URL = {
        return self.storeDirectoryURL.appendingPathComponent(self.sqlName)
        //       return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqlName)
    }()
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dprados.CoreDataSpike" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: self.storeName, withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let coordinator : NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var options = [AnyHashable: Any]()
        options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(value: true as Bool)
        options[NSInferMappingModelAutomaticallyOption] = NSNumber(value: true as Bool)
        
        do {
            try FileManager.default.createDirectory(at: self.storeDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Unresolved error: local database storage position is unavailable.")
            abort()
        }
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data." as AnyObject?
            dict[NSUnderlyingErrorKey] = error as? NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    static func save() {
        CoreDataStack.defaultStack.saveContext()
    }
    
    func enableEnsemble() {
        CoreDataStack.defaultStack.cloudFileSystem = CDEICloudFileSystem(ubiquityContainerIdentifier: nil)
        CoreDataStack.defaultStack.ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: self.storeName, persistentStore: self.storeURL, managedObjectModelURL: self.modelURL, cloudFileSystem: CoreDataStack.defaultStack.cloudFileSystem)
        CoreDataStack.defaultStack.ensemble!.delegate = CoreDataStack.defaultStack
    }
    
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, didSaveMergeChangesWith notification: Notification!) {
        CoreDataStack.defaultStack.managedObjectContext.performAndWait({ () -> Void in
            CoreDataStack.defaultStack.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        })
        if notification != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.02 * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC), execute: {
                NSLog("Database was updated from iCloud")
                CoreDataStack.defaultStack.saveContext()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DB_UPDATED"), object: nil)
            })
        }
    }
    
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [AnyObject]!) -> [AnyObject]! {
        NSLog("%@", (objects as NSArray).value(forKeyPath: "uniqueIdentifier") as! [AnyObject])
        return (objects as NSArray).value(forKeyPath: "uniqueIdentifier") as! [AnyObject]
    }
    
    func syncWithCompletion(_ completion: (() -> Void)!) {
        
        if CoreDataStack.defaultStack.ensemble!.isLeeched {
            CoreDataStack.defaultStack.ensemble!.merge(completion: { (error:Error?) -> Void in
                if error != nil && (error! as NSError).code != 103 {
                    print("Error in merge: %@", error!)
                } else if error != nil && (error! as NSError).code == 103 {
                    self.perform("syncWithCompletion:", with: nil, afterDelay: 1.0)
                } else {
                    if completion != nil {
                        completion()
                    }
                }
            })
        } else {
            CoreDataStack.defaultStack.ensemble!.leechPersistentStore(completion: { (error:Error?) -> Void in
                if error != nil && (error! as NSError).code != 103 {
                    print("Error in leech: %@", error!)
                } else if error != nil && (error! as NSError).code == 103 {
                    self.perform("syncWithCompletion:", with: nil, afterDelay: 1.0)
                } else {
                    self.perform("syncWithCompletion:", with: nil, afterDelay: 1.0)
                    if completion != nil {
                        completion()
                    }
                }
            })
        }
        
    }
    
}
