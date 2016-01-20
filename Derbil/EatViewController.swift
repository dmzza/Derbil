//
//  EatViewController.swift
//  Chubbyy
//
//  Created by David Mazza on 8/19/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsTodaysMealCount = "TodaysMealCount"

enum FoodGroup {
  case Grain
  case Vegetable
  case Fruit
  case Protein
  case Dairy
}

enum FatContent {
  case None
  case Lean
  case Moderate
  case Fatty
}

enum SugarContent {
  case None
  case Low
  case Natural
  case Sweet
}

struct Food {
  var group: FoodGroup
  var fat: FatContent
  var sugar: SugarContent
  var name: String
}

class EatViewController: UIViewController {
    var delegate: EatViewControllerDelegate?
    
    @IBOutlet var mealPicker: UISlider!
    @IBOutlet var mealButton: UIButton!
    var faceView: FaceView?
    var animator: UIDynamicAnimator?
  
  let foods = [
    Food(group: FoodGroup.Grain,
      fat: FatContent.Lean,
      sugar: SugarContent.Low,
      name: "Whole Wheat Rustic Bread"),
    Food(group: FoodGroup.Vegetable,
      fat: FatContent.Fatty,
      sugar: SugarContent.Low,
      name: "French Fries"),
    Food(group: FoodGroup.Fruit,
      fat: FatContent.None,
      sugar: SugarContent.Natural,
      name: "Pineapple Chunks"),
    Food(group: FoodGroup.Protein,
      fat: FatContent.Fatty,
      sugar: SugarContent.None,
      name: "Extra Crispy Chicken"),
    Food(group: FoodGroup.Dairy,
      fat: FatContent.Moderate,
      sugar: SugarContent.Sweet,
      name: "Butter Pecan Ice Cream")
  ]
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
  @IBAction func mealPickerChanged(sender: UISlider) {
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
      let foodIndex = Int(self.mealPicker.value)
      
      self.mealButton.setTitle(self.foods[foodIndex].name, forState: UIControlState.Normal)
    }

}

protocol EatViewControllerDelegate {
    func eatViewControllerDidDismiss(vc: EatViewController)
}
