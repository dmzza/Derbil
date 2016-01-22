//
//  EatViewController.swift
//  Chubbyy
//
//  Created by David Mazza on 8/19/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit
import Foundation

let kUserDefaultsMeals = "RecentMeals"



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
  
  let foods = [
    Food(group: Food.Group.Grain,
      fat: Food.FatContent.Lean,
      sugar: Food.SugarContent.Low,
      name: "Whole Wheat Rustic Bread"),
    Food(group: Food.Group.Vegetable,
      fat: Food.FatContent.Fatty,
      sugar: Food.SugarContent.Low,
      name: "French Fries", icon: "fries"),
    Food(group: Food.Group.Fruit,
      fat: Food.FatContent.None,
      sugar: Food.SugarContent.Natural,
      name: "Pineapple Chunks"),
    Food(group: Food.Group.Protein,
      fat: Food.FatContent.Fatty,
      sugar: Food.SugarContent.None,
      name: "Extra Crispy Chicken"),
    Food(group: Food.Group.Dairy,
      fat: Food.FatContent.Moderate,
      sugar: Food.SugarContent.Sweet,
      name: "Butter Pecan Ice Cream", icon: "popsicle")
  ]
  var meals: [Food] = []
  var selectedFood: Food {
    didSet {
      self.mealButton.setTitle(self.selectedFood.name, forState: UIControlState.Normal)
      self.mealIcon.image = UIImage(named: self.selectedFood.iconName)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    selectedFood = self.foods[0]
    super.init(coder: aDecoder)
  }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = NSUserDefaults.standardUserDefaults()
      
      if let meals: [Food] = extractValuesFromPropertyListArray(userDefaults.arrayForKey(kUserDefaultsMeals)) {
        self.meals = meals
      }
      
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameNewDayBegan,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (note) -> Void in
                self.pruneLeastRecentMeal()
        }
      
      self.grainBarHeight.constant = 50.0
      self.vegetableBarHeight.constant = 99.0
      self.fruitBarHeight.constant = 69.0
      self.proteinBarHeight.constant = 5.0
      self.dairyBarHeight.constant = 34.0
    }
    
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.selectedFood = self.foods[0]
  }
  @IBAction func mealPickerChanged(sender: UISlider) {
    sender.value = round(sender.value)
    let foodIndex = Int(sender.value)
    self.selectedFood = self.foods[foodIndex]
  }
  
  @IBAction func eatMeal(sender: AnyObject) {
    self.meals.append(self.selectedFood)
    saveValuesToDefaults(self.meals, key: kUserDefaultsMeals)
    self.delegate?.eatViewControllerDidDismiss(self)
  }
    
  func updateFoodGroupBar(heightConstraint: NSLayoutConstraint, group: Food.Group, servings: Int) {
    // TODO
  }
  
  func pruneLeastRecentMeal() {
    // TODO
  }

}

protocol EatViewControllerDelegate {
    func eatViewControllerDidDismiss(vc: EatViewController)
}
