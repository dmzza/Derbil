//
//  AppDelegate.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit
import Timepiece

let kInAppNotificationReceived = "InAppNotificationReceived"
let kNotificationNameNewDayBegan = "NewDayBegan"
let kUserDefaultsLastDailyReset = "LastDailyReset"
let kUserDefaultsMealCount = "MealCount"
let kUserDefaultsWalkCount = "WalkCount"
let kUserDefaultsSleepHours = "SleepHours"
let kUserDefaultsSleepBegin = "SleepBegin"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if let options = launchOptions {
            if let note = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                self.application(UIApplication.sharedApplication(), didReceiveLocalNotification: note)
            }
        }
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.doubleForKey(kUserDefaultsLastDailyReset) == 0 {
            userDefaults.setDouble(0.0, forKey: kUserDefaultsLastDailyReset)
         }
        if userDefaults.integerForKey(kUserDefaultsMealCount) == 0 {
            userDefaults.setInteger(1, forKey: kUserDefaultsMealCount)
         }
        if userDefaults.integerForKey(kUserDefaultsWalkCount) == 0 {
            userDefaults.setInteger(1, forKey: kUserDefaultsWalkCount)
         }
        if userDefaults.integerForKey(kUserDefaultsSleepHours) == 0 {
            userDefaults.setInteger(1, forKey: kUserDefaultsSleepHours)
         }
        if userDefaults.doubleForKey(kUserDefaultsSleepBegin) == 0 {
            userDefaults.setDouble(0.0, forKey: kUserDefaultsSleepBegin)
         }
        
        let lastDailyReset = userDefaults.doubleForKey(kUserDefaultsLastDailyReset)
        let now = NSDate().change(timeZone: NSTimeZone.localTimeZone())
        if (lastDailyReset < now.beginningOfDay.timeIntervalSince1970) {
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationNameNewDayBegan, object: nil)
            userDefaults.setDouble(now.timeIntervalSince1970, forKey: kUserDefaultsLastDailyReset)
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
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kInAppNotificationReceived, object: self, userInfo: ["notification": notification]))
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        completionHandler()
    }


}

