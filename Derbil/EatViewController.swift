//
//  EatViewController.swift
//  Chubbyy
//
//  Created by David Mazza on 8/19/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsTodaysMealCount = "TodaysMealCount"

class EatViewController: UIViewController {
    var delegate: EatViewControllerDelegate?
    
    @IBOutlet var mealPicker: UISlider!
    @IBOutlet var mealButton: UIButton!
    var faceView: FaceView?
    var animator: UIDynamicAnimator?
    
    var meals: Int = 0
    let mealsPerDay = 4

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameNewDayBegan,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (note) -> Void in
                userDefaults.setInteger(0, forKey: kUserDefaultsTodaysMealCount)
        }
        
        self.meals = userDefaults.integerForKey(kUserDefaultsTodaysMealCount)
        self.animator = UIDynamicAnimator(referenceView: self.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateMealButton()
    }
    
    @IBAction func eatMeal(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentMeals: Int = userDefaults.integerForKey(kUserDefaultsMealCount)
        let todaysMeals: Int = userDefaults.integerForKey(kUserDefaultsTodaysMealCount)
        
        self.meals = todaysMeals + 1
        userDefaults.setInteger(currentMeals + 1, forKey: kUserDefaultsMealCount)
        userDefaults.setInteger(self.meals, forKey: kUserDefaultsTodaysMealCount)
        self.updateMealButton()
        
        for i in 1...10 {
            NSTimer.scheduledTimerWithTimeInterval(0.05 * Double(i), target: self, selector: "giveHeart", userInfo: nil, repeats: false)
        }
        
        self.delegate?.eatViewControllerDidDismiss(self)
    }
    
    func giveHeart() {
    }
    
    func updateMealButton() {
        switch(self.meals) {
        case 0:
            self.mealButton.setTitle("Breakfast", forState: UIControlState.Normal)
            break
        case 1:
            self.mealButton.setTitle("Lunch", forState: UIControlState.Normal)
            break
        case 2:
            self.mealButton.setTitle("Dinner", forState: UIControlState.Normal)
            break
        default:
            self.mealButton.setTitle("", forState: UIControlState.Normal)
            
        }
    }

}

protocol EatViewControllerDelegate {
    func eatViewControllerDidDismiss(vc: EatViewController)
}
