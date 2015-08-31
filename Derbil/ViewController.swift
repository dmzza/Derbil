//
//  ViewController.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsTodaysWalkCount = "TodaysWalkCount"

class ViewController: UIViewController, WalkViewControllerDelegate {

    @IBOutlet weak var faceContainer: UIView!
    var faceView: FaceView?
    
    @IBOutlet var firstHeart: UIImageView!
    @IBOutlet var secondHeart: UIImageView!
    @IBOutlet var thirdHeart: UIImageView!
    
    let walksPerDay = 4
    var walks: Int = 0 {
        didSet {
            self.firstHeart.hidden = walks < 1
            self.secondHeart.hidden = walks < 2
            self.thirdHeart.hidden = walks < 3
        }
    }
    let happyWalkThreshold: NSTimeInterval = 120
    let notificationTitle = "Chubbyy needs love"
    let morningNotificationBody = "🌞"
    let morningNotificationThought = "Wake up! I need to pee, take me outside."
    let afternoonNotificationBody = "😋"
    let afternoonNotificationThought = "That was a big lunch. I need to pee again."
    let eveningNotificationBody = "🌝"
    let eveningNotificationThought = "Take me for a walk before bed."
    let warningNotificationBody = "😖"
    let firstWarningNotificationThought = "Okay, seriously I need to go outside."
    let finalWarningNotificationThought = "If we wait any longer there is gonna be trouble!"
    let accidentNotificationThought = "Oops, I couldn't hold it any longer."
    let secondsPerDay: Double = 60 * 60 * 24
    let morningNotificationTime: NSTimeInterval = 9.0 * 3600
    let afternoonNotificationTime: NSTimeInterval = 15.0 * 3600
    let eveningNotificationTime: NSTimeInterval = 21.0 * 3600
    let firstWarningInterval: NSTimeInterval = 0.5 * 3600;
    let finalWarningInterval: NSTimeInterval = 1.5 * 3600;
    let accidentInterval: NSTimeInterval = 1.75 * 3600;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        self.scheduleNotifications()
        NSNotificationCenter.defaultCenter().addObserverForName(kInAppNotificationReceived,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { (note) -> Void in
                if let userInfo = (((note.userInfo! as Dictionary)["notification"])! as! UILocalNotification).userInfo {
                    if let thought = userInfo["thought"] as? String {
                        self.speak(thought)
                    }
                }
            })
        
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameNewDayBegan,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (note) -> Void in
                userDefaults.setInteger(0, forKey: kUserDefaultsTodaysWalkCount)
        }
        
        self.walks = userDefaults.integerForKey(kUserDefaultsTodaysWalkCount)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.faceView == nil) {
            let face: Face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
                leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
                rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
            self.faceView = FaceView(face: face, frame: self.faceContainer.bounds)
            self.faceContainer.addSubview(self.faceView!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scheduleNotifications() {
        let morningNotification = self.notification(morningNotificationTime, body: morningNotificationBody, title: notificationTitle, thought:morningNotificationThought)
        let afternoonNotification = self.notification(afternoonNotificationTime, body: afternoonNotificationBody, title: notificationTitle, thought:morningNotificationThought)
        let eveningNotification = self.notification(eveningNotificationTime, body: eveningNotificationBody, title: notificationTitle, thought:morningNotificationThought)
        var secondsToSoonestNotification = secondsPerDay
        let now = NSDate().timeIntervalSinceReferenceDate
        let soonestNotification: NSTimeInterval
        
        var interval = morningNotification.fireDate!.timeIntervalSinceReferenceDate - now
        if interval < secondsToSoonestNotification {
            secondsToSoonestNotification = interval
        }
        interval = afternoonNotification.fireDate!.timeIntervalSinceReferenceDate - now
        if interval < secondsToSoonestNotification {
            secondsToSoonestNotification = interval
        }
        interval = eveningNotification.fireDate!.timeIntervalSinceReferenceDate - now
        if interval < secondsToSoonestNotification {
            secondsToSoonestNotification = interval
        }
        soonestNotification = now + secondsToSoonestNotification
        
        let firstWarningNotification = self.notification(soonestNotification + firstWarningInterval, body: warningNotificationBody, title: notificationTitle, thought: firstWarningNotificationThought)
        let finalWarningNotification = self.notification(soonestNotification + finalWarningInterval, body: warningNotificationBody, title: notificationTitle, thought: finalWarningNotificationThought)
        let accidentNotification = self.notification(soonestNotification + accidentInterval, body: warningNotificationBody, title: notificationTitle, thought: accidentNotificationThought)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduleLocalNotification(morningNotification)
        UIApplication.sharedApplication().scheduleLocalNotification(afternoonNotification)
        UIApplication.sharedApplication().scheduleLocalNotification(eveningNotification)
        UIApplication.sharedApplication().scheduleLocalNotification(firstWarningNotification)
        UIApplication.sharedApplication().scheduleLocalNotification(finalWarningNotification)
        UIApplication.sharedApplication().scheduleLocalNotification(accidentNotification)
    }
    
    func notification(intervalFromMidnight: NSTimeInterval, body: String, title: String, thought: String) -> UILocalNotification {
        let note = UILocalNotification()
        let secondsSinceMidnight = (NSDate().timeIntervalSinceReferenceDate % secondsPerDay) + Double(NSTimeZone(abbreviation: "PST")!.secondsFromGMT)
        var intervalFromNow = intervalFromMidnight - secondsSinceMidnight
        
        note.alertBody = body
        note.alertTitle = title
        note.userInfo = ["thought": thought]
        note.category = "myCategory"
        if intervalFromNow < 0 {
            intervalFromNow += secondsPerDay // bump it out to tomorrow
        }
        note.fireDate = NSDate(timeIntervalSinceNow: intervalFromNow)
        note.timeZone = NSTimeZone(abbreviation: "PST")
        print("\(note.fireDate?.description)")
        return note
    }
    
    func smile(duration: NSTimeInterval) {
        if let view: FaceView = self.faceView {
            let face: Face = self.faceView!.face
            view.face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Smiling, Face.Part.Mouth),
                leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
                rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
            delay(duration) { () -> () in
                view.face = face
            }
        }
    }
    
    func speak(thoughts: String) {
        let alert: UIAlertController = UIAlertController(title: nil, message: thoughts, preferredStyle:UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTripleTap(sender: UITapGestureRecognizer) {
        let secondsSinceMidnight = (NSDate().timeIntervalSinceReferenceDate % secondsPerDay) + Double(NSTimeZone(abbreviation: "PST")!.secondsFromGMT)
        let instaNote: UILocalNotification = self.notification(secondsSinceMidnight + 5, body: "😖", title: notificationTitle, thought: "Hello")
        UIApplication.sharedApplication().scheduleLocalNotification(instaNote)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WalkViewControllerSegue" {
            let vc: WalkViewController = (segue.destinationViewController as! UINavigationController).topViewController as! WalkViewController
            vc.delegate = self
        }
    }

    func didComplete(controller: WalkViewController, elapsedTime: NSTimeInterval) {
        if elapsedTime >= happyWalkThreshold {
            self.smile(elapsedTime / 10)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let currentWalks: Int = userDefaults.integerForKey(kUserDefaultsWalkCount)
            let todaysWalks: Int = userDefaults.integerForKey(kUserDefaultsTodaysWalkCount)
            
            self.walks = todaysWalks + 1
            userDefaults.setInteger(currentWalks + 1, forKey: kUserDefaultsWalkCount)
            userDefaults.setInteger(self.walks, forKey: kUserDefaultsTodaysWalkCount)
            
        }
    }
}
