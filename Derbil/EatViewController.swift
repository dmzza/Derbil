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
    @IBOutlet var faceContainer: UIView!
    @IBOutlet var mealButton: UIButton!
    @IBOutlet var firstHeart: UIImageView!
    @IBOutlet var secondHeart: UIImageView!
    @IBOutlet var thirdHeart: UIImageView!
    var faceView: FaceView?
    
    var meals: Int = 0 {
        didSet {
            self.firstHeart.hidden = meals < 1
            self.secondHeart.hidden = meals < 2
            self.thirdHeart.hidden = meals < 3
        }
    }
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
        self.updateMealButton()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eatMeal(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentMeals: Int = userDefaults.integerForKey(kUserDefaultsMealCount)
        let todaysMeals: Int = userDefaults.integerForKey(kUserDefaultsTodaysMealCount)
        
        self.meals = todaysMeals + 1
        userDefaults.setInteger(currentMeals + 1, forKey: kUserDefaultsMealCount)
        userDefaults.setInteger(self.meals, forKey: kUserDefaultsTodaysMealCount)
        self.updateMealButton()
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
