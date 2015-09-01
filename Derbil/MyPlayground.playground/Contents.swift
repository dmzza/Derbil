//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

var str = "Hello, playground"
let kUserDefaultsSleepBegin = "SleepBegin"

var play = Playplace()
XCPShowView("Playground VC", view: play.view)

//play.scheduleNotifications()
//
//play.wakeUp()

play.flyingHeart()


class Playplace: UIViewController {

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
    var secondsSinceMidnight: NSTimeInterval {
        return (NSDate().timeIntervalSinceReferenceDate % secondsPerDay) + Double(NSTimeZone.localTimeZone().secondsFromGMT)
    }
    var heart: UIImageView = UIImageView(image: UIImage(named: "heart"))
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        XCPShowView("View", view: self.view)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        heart.frame = CGRect(x: 100, y: 300, width: 50, height: 50)
        heart.backgroundColor = UIColor.blackColor()
        self.view.addSubview(heart)
    }
    
    func flyingHeart() {
        
        
        let animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        let behavior: FlyingHeartBehavior = FlyingHeartBehavior(items: [heart], endPoint: CGPoint(x: 0, y: 0)) // firstHeart.center
        animator.addBehavior(behavior)
        
    }
    
    
    func wakeUp() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sleepBegan = NSDate(timeIntervalSinceNow: -10820).timeIntervalSince1970 //userDefaults.doubleForKey(kUserDefaultsSleepBegin)
        let now = NSDate().timeIntervalSince1970
        let currentHoursSlept = 2 //userDefaults.integerForKey(kUserDefaultsSleepBegin)
        var hoursSlept: Int = 0
        if sleepBegan > (now - 60*60*24) {
            hoursSlept = Int((now - sleepBegan) / (60*60))
        }
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
        soonestNotification = self.secondsSinceMidnight + secondsToSoonestNotification
        let firstTime: NSTimeInterval = soonestNotification + firstWarningInterval
        
        let firstWarningNotification = self.notification(firstTime, body: warningNotificationBody, title: notificationTitle, thought: firstWarningNotificationThought)
        let finalWarningNotification = self.notification(soonestNotification + finalWarningInterval, body: warningNotificationBody, title: notificationTitle, thought: finalWarningNotificationThought)
        let accidentNotification = self.notification(soonestNotification + accidentInterval, body: warningNotificationBody, title: notificationTitle, thought: accidentNotificationThought)
        
//        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        UIApplication.sharedApplication().scheduleLocalNotification(morningNotification)
//        UIApplication.sharedApplication().scheduleLocalNotification(afternoonNotification)
//        UIApplication.sharedApplication().scheduleLocalNotification(eveningNotification)
//        UIApplication.sharedApplication().scheduleLocalNotification(firstWarningNotification)
//        UIApplication.sharedApplication().scheduleLocalNotification(finalWarningNotification)
//        UIApplication.sharedApplication().scheduleLocalNotification(accidentNotification)
    }

    func notification(intervalFromMidnight: NSTimeInterval, body: String, title: String, thought: String) -> UILocalNotification {
        let note = UILocalNotification()
        var intervalFromNow = intervalFromMidnight - self.secondsSinceMidnight
        
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


}


class FlyingHeartBehavior: UIDynamicBehavior {
    
    init(items: [UIDynamicItem], endPoint: CGPoint) {
        super.init()
        
        for (_, item) in items.enumerate() {
//            let snapBehavior: UISnapBehavior = UISnapBehavior(item: item, snapToPoint: endPoint)
//            let pushBehavior: UIPushBehavior = UIPushBehavior(items: [item], mode: UIPushBehaviorMode.Instantaneous)
            let gravityBehavior: UIGravityBehavior = UIGravityBehavior(items: [item])
            gravityBehavior.angle = 1.0
//            snapBehavior.damping = 0.65;
//            pushBehavior.setAngle(1.0, magnitude: 1.0)
            
//            self.addChildBehavior(snapBehavior)
//            self.addChildBehavior(pushBehavior)
            self.addChildBehavior(gravityBehavior)
        }
        
    }
    
}