//
//  AppDelegate.swift
//  ISB Ace
//
//  Created by e1615998 on 3/19/16.
//  Copyright © 2016 ISB Software Development Club. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //TODO: figure out how to UNREGISTER background fetch if the user disables the setting
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("logged_in"){
            var interval = 10*60.0
            if let setting = NSUserDefaults.standardUserDefaults().objectForKey("update_interval"){
                interval = (setting as! NSNumber).doubleValue * 60
            }
            application.setMinimumBackgroundFetchInterval(interval)
            
            if(UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))))
            {
                let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
                notificationCategory.identifier = "INVITE_CATEGORY"
                notificationCategory.setActions([UIUserNotificationAction()], forContext: UIUserNotificationActionContext.Default)
                
                //registerting for the notification.
                application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[.Sound, .Alert, .Badge], categories: nil))
            }
            else{
                //do iOS 7 stuff, which is pretty much nothing for local notifications.
            }
        }
        return true
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    let api = PowerAPI.sharedInstance
    var oldSections = [Section]()
    var completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("BG fetch start")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.handleTranscript(_:)), name:"transcript_parsed", object: nil)
        self.completionHandler = completionHandler
        self.oldSections = api.sections
        let defaults = NSUserDefaults.standardUserDefaults()
        if let un = defaults.objectForKey("username") as? String,let pw = defaults.objectForKey("password") as? String{
            api.authenticate("powerschool.isb.ac.th", username: un, password: pw, fetchTranscript: true)
        }else{
            print("tried bg fetch but no un and/or password")
        }
    }
    func handleTranscript(notification : NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("BG fetch finit")
        if let handler = self.completionHandler{
            if api.sections.count != 0{
                for newSection in api.sections{
                    for oldSection in self.oldSections{
                        //for every new section try to find an equivalent old section
                        if newSection.name == oldSection.name && newSection.reportingTerm == oldSection.reportingTerm{
                            if newSection.finalGrade["percent"] != oldSection.finalGrade["percent"]{
                                let app = UIApplication.sharedApplication()
                                if app.scheduledLocalNotifications?.count > 0{
                                    app.cancelAllLocalNotifications()
                                }
                                let notification = UILocalNotification()
                                notification.fireDate = NSDate()
                                notification.timeZone = NSTimeZone.defaultTimeZone()
                                notification.repeatInterval = NSCalendarUnit(rawValue: 0)
                                notification.soundName = UILocalNotificationDefaultSoundName
                                var bodyTitle = ""
                                if #available(iOS 8.2, *) {
                                    notification.alertTitle = "Grade Changed"
                                    bodyTitle = "Grade Changed\n"
                                }
                                if let percent = newSection.finalGrade["percent"]{
                                    notification.alertBody = "\(bodyTitle)Your \(newSection.name) grade has changed to \(percent)%%"
                                    app.scheduleLocalNotification(notification)
                                }else{
                                    //if no new grade then powerschool has encountered an error and no need to display notification
                                }
                            }
                        }
                    }
                }
                handler(UIBackgroundFetchResult.NewData)
            }else{
                handler(UIBackgroundFetchResult.Failed)
            }
        }
        //print(api.studentInformation)
    }
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yourcompany.TestRSS" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("RSSDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
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
}

