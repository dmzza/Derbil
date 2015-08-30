//
//  SleepViewController.swift
//  Derbil
//
//  Created by David Mazza on 8/19/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

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
    let oneDay: NSTimeInterval = 60 * 60 * 24
    let oneHour: NSTimeInterval = 60 * 60

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let currentHoursSlept = userDefaults.integerForKey(kUserDefaultsSleepBegin)
        var hoursSlept: Int = 0
        if sleepBegan > (now - oneDay) {
            hoursSlept = Int((now - sleepBegan) % oneHour)
        }
        userDefaults.setInteger(currentHoursSlept + hoursSlept, forKey: kUserDefaultsSleepBegin)
        self.hoursSleptToday += hoursSlept
        userDefaults.setDouble(0.0, forKey: kUserDefaultsSleepBegin)
        self.bedtimeButton.hidden = false
        self.faceView?.blink()
    }

    @IBAction func sleep(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let now = NSDate().timeIntervalSince1970
        
        self.hoursSleptToday++
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
