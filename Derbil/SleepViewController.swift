//
//  SleepViewController.swift
//  Chubbyy
//
//  Created by David Mazza on 8/19/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsTodaysHoursSlept = "TodaysHoursSlept"

class SleepViewController: UIViewController {
    @IBOutlet var faceContainer: UIView!
    @IBOutlet var firstHeart: UIImageView!
    @IBOutlet var secondHeart: UIImageView!
    @IBOutlet var thirdHeart: UIImageView!
    @IBOutlet var bedtimeButton: UIButton!
    
    var faceView: FaceView?
    var hoursSleptToday: Int = 0 {
        didSet {
            self.firstHeart.hidden = hoursSleptToday < 1
            self.secondHeart.hidden = hoursSleptToday < 5
            self.thirdHeart.hidden = hoursSleptToday < 8
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameNewDayBegan,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (note) -> Void in
                userDefaults.setInteger(0, forKey: kUserDefaultsTodaysHoursSlept)
        }
        
        self.hoursSleptToday = userDefaults.integerForKey(kUserDefaultsTodaysHoursSlept)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let face: Face = Face(
            mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
            leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
            rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
        if (self.faceView == nil) {
            self.faceView = FaceView(face: face, frame: self.faceContainer.bounds)
            self.faceContainer.addSubview(self.faceView!)
        } else {
            self.faceView?.face = face
        }
        
        self.wakeUp()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wakeUp() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sleepBegan = userDefaults.doubleForKey(kUserDefaultsSleepBegin)
        let now = NSDate().timeIntervalSince1970
        let currentSleptHours: Int = userDefaults.integerForKey(kUserDefaultsSleepHours)
        let todaysHoursSlept: Int = userDefaults.integerForKey(kUserDefaultsTodaysHoursSlept)
        
        var hoursSlept: Int = 0
        if sleepBegan > (now - NSCalendarUnit.Day.interval) {
            hoursSlept = Int((now - sleepBegan) / NSCalendarUnit.Hour.interval)
        }
        self.hoursSleptToday = todaysHoursSlept + hoursSlept
        userDefaults.setInteger(currentSleptHours + hoursSlept, forKey: kUserDefaultsSleepHours)
        userDefaults.setInteger(self.hoursSleptToday, forKey: kUserDefaultsTodaysHoursSlept)
        userDefaults.setDouble(0.0, forKey: kUserDefaultsSleepBegin)
        self.bedtimeButton.hidden = false
        self.faceView?.blink()
    }

    @IBAction func sleep(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let now = NSDate().timeIntervalSince1970
        let currentSleptHours: Int = userDefaults.integerForKey(kUserDefaultsSleepHours)
        let todaysHoursSlept: Int = userDefaults.integerForKey(kUserDefaultsTodaysHoursSlept)
        
        self.hoursSleptToday = todaysHoursSlept + 1
        userDefaults.setInteger(currentSleptHours + 1, forKey: kUserDefaultsSleepHours)
        userDefaults.setInteger(self.hoursSleptToday, forKey: kUserDefaultsTodaysHoursSlept)
        userDefaults.setDouble(now, forKey: kUserDefaultsSleepBegin)
        self.bedtimeButton.hidden = true
        self.faceView?.face = Face(
            mouth: Face.Name.MouthName(Face.Mouth.Smiling, Face.Part.Mouth),
            leftEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Left),
            rightEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Right))
        self.faceView?.snore()
    }
    
    @IBAction func nap(sender: AnyObject) {
        self.hoursSleptToday = 0
        self.sleep(sender)
    }

}
