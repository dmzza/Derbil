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
  let group: FoodGroup
  let fat: FatContent
  let sugar: SugarContent
  let name: String
  let icon: String?
  func iconName() -> String {
    if let name = self.icon {
      return "\(name).png"
    }
    switch(self.group) {
    case .Grain: return "bread.png"
    case .Vegetable: return "eggplant.png"
    case .Fruit: return "fruit.png"
    case .Protein: return "meal.png"
    case .Dairy: return "cheese.png"
    }
  }
}

class EatViewController: UIViewController {
    var delegate: EatViewControllerDelegate?
    
    @IBOutlet var mealPicker: UISlider!
    @IBOutlet var mealButton: UIButton!
  @IBOutlet var mealIcon: UIImageView!
  
  @IBOutlet var grainBarHeight: NSLayoutConstraint!
  @IBOutlet var vegetableBarHeight: NSLayoutConstraint!
  @IBOutlet var fruitBarHeight: NSLayoutConstraint!
  @IBOutlet var proteinBarHeight: NSLayoutConstraint!
  @IBOutlet var dairyBarHeight: NSLayoutConstraint!
  
    var faceView: FaceView?
    var animator: UIDynamicAnimator?
  
  let foods = [
    Food(group: FoodGroup.Grain,
      fat: FatContent.Lean,
      sugar: SugarContent.Low,
      name: "Whole Wheat Rustic Bread", icon: nil),
    Food(group: FoodGroup.Vegetable,
      fat: FatContent.Fatty,
      sugar: SugarContent.Low,
      name: "French Fries", icon: "fries"),
    Food(group: FoodGroup.Fruit,
      fat: FatContent.None,
      sugar: SugarContent.Natural,
      name: "Pineapple Chunks", icon: nil),
    Food(group: FoodGroup.Protein,
      fat: FatContent.Fatty,
      sugar: SugarContent.None,
      name: "Extra Crispy Chicken", icon: nil),
    Food(group: FoodGroup.Dairy,
      fat: FatContent.Moderate,
      sugar: SugarContent.Sweet,
      name: "Butter Pecan Ice Cream", icon: "popsicle")
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
      
      self.grainBarHeight.constant = 50.0
      self.vegetableBarHeight.constant = 99.0
      self.fruitBarHeight.constant = 69.0
      self.proteinBarHeight.constant = 5.0
      self.dairyBarHeight.constant = 34.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateMealButton()
    }
  @IBAction func mealPickerChanged(sender: UISlider) {
    sender.value = round(sender.value)
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
      let food = self.foods[foodIndex]
      
      self.mealButton.setTitle(food.name, forState: UIControlState.Normal)
      self.mealIcon.image = UIImage(named: food.iconName())
    }

}

protocol EatViewControllerDelegate {
    func eatViewControllerDidDismiss(vc: EatViewController)
}
