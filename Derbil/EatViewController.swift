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
  
  @IBOutlet var topBarsView: UIView!
  @IBOutlet var bottomBarsView: UIView!
  
  @IBOutlet var grainBarHeight: NSLayoutConstraint!
  @IBOutlet var vegetableBarHeight: NSLayoutConstraint!
  @IBOutlet var fruitBarHeight: NSLayoutConstraint!
  @IBOutlet var proteinBarHeight: NSLayoutConstraint!
  @IBOutlet var dairyBarHeight: NSLayoutConstraint!
  
  static let foods = [
    Food(group: Food.Group.Grain,
      fat: Food.FatContent.Lean,
      sugar: Food.SugarContent.Low,
      name: "Whole Wheat Bread"),
    Food(group: Food.Group.Grain,
      fat: Food.FatContent.Fatty,
      sugar: Food.SugarContent.Low,
      name: "Croissant", icon: "croissant"),
    Food(group: Food.Group.Vegetable,
      fat: Food.FatContent.Fatty,
      sugar: Food.SugarContent.Low,
      name: "French Fries", icon: "fries"),
    Food(group: Food.Group.Vegetable,
      fat: Food.FatContent.Moderate,
      sugar: Food.SugarContent.Natural,
      name: "Eggplant"),
    Food(group: Food.Group.Fruit,
      fat: Food.FatContent.None,
      sugar: Food.SugarContent.Natural,
      name: "Pineapple Chunks"),
    Food(group: Food.Group.Fruit,
      fat: Food.FatContent.None,
      sugar: Food.SugarContent.Sweet,
      name: "Candy Apple"),
    Food(group: Food.Group.Protein,
      fat: Food.FatContent.Fatty,
      sugar: Food.SugarContent.None,
      name: "Extra Crispy Chicken"),
    Food(group: Food.Group.Protein,
      fat: Food.FatContent.Lean,
      sugar: Food.SugarContent.None,
      name: "Skirt Steak"),
    Food(group: Food.Group.Dairy,
      fat: Food.FatContent.Moderate,
      sugar: Food.SugarContent.Sweet,
      name: "Butter Pecan Ice Cream", icon: "popsicle"),
    Food(group: Food.Group.Dairy,
      fat: Food.FatContent.Lean,
      sugar: Food.SugarContent.Natural,
      name: "Swiss Cheese")
  ]
  static var meals: [Food] {
    get {
      let userDefaults = NSUserDefaults.standardUserDefaults()
      if let meals: [Food] = extractValuesFromPropertyListArray(userDefaults.arrayForKey(kUserDefaultsMeals)) {
        return meals
      } else {
        return []
      }
    }
  }
  var foodIndexByGroup: [Food.Group: Int] = [:]
  var servings: [Food.Group:Int] = [.Grain: 0, .Vegetable: 0, .Fruit: 0, .Protein: 0, .Dairy: 0]
  var selectedFood: Food {
    didSet {
      self.mealButton.setTitle(self.selectedFood.name, forState: UIControlState.Normal)
      self.mealIcon.image = UIImage(named: self.selectedFood.iconName)
      self.resetFoodGroupBarsFromRecentMeals()
      self.updateFoodGroupBar(self.selectedFood.group, servings: self.servings[self.selectedFood.group]! + 1)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    selectedFood = EatViewController.foods[0]
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for meal in EatViewController.meals {
      self.servings[meal.group]! += 1
    }
  }
    
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.selectedFood = self.mealForFoodGroup(.Grain)
    let barViews = [ self.topBarsView.subviews, self.bottomBarsView.subviews].flatMap { $0 }
    
    for bar in barViews {
      let barRadius = bar.frame.width / 2
      bar.backgroundColor = UIColor.whiteColor()
      bar.layer.cornerRadius = barRadius
      bar.layer.borderColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.9, alpha: 1.0).CGColor
      bar.layer.borderWidth = barRadius - 2.0
    }
  }
  
  @IBAction func mealPickerChanged(sender: UISlider) {
    sender.value = round(sender.value)
    self.mealPicked(Int(sender.value))
  }
  
  @IBAction func mealPickerReleasedInside(sender: UISlider) {
    self.mealPicked(Int(sender.value))
  }
  
  @IBAction func mealPickerReleasedOutside(sender: UISlider) {
    self.mealPicked(Int(sender.value))
  }
  
  func mealPicked(foodGroupIndex: Int) {
    self.selectedFood = self.mealForFoodGroup(Food.Group(rawValue: foodGroupIndex)!)
  }
  
  @IBAction func eatMeal(sender: AnyObject) {
    var meals = EatViewController.meals
    let group = self.selectedFood.group
    self.foodIndexByGroup = [:]
    
    self.view.layoutIfNeeded()
    UIView.animateWithDuration(0.15) { () -> Void in
      self.heightConstraintForFoodGroup(group).constant = (CGFloat(100) * CGFloat(self.servings[group]! - 1) / CGFloat(group.recommendedServings)) + 60
      self.view.layoutIfNeeded()
    }
    meals.append(self.selectedFood)
    saveValuesToDefaults(meals, key: kUserDefaultsMeals)
    self.servings[group]! += 1
    self.selectedFood = self.mealForFoodGroup(group)
  }
  
  @IBAction func done(sender: AnyObject) {
    self.delegate?.eatViewControllerDidDismiss(self)
  }
  
  func mealForFoodGroup(group: Food.Group) -> Food {
    if let foodIndex = self.foodIndexByGroup[group] {
      return EatViewController.foods[foodIndex]
    } else {
      // count options
      let optionsInGroup: Int = EatViewController.foods.reduce(0, combine: { (count, food) -> Int in
        if food.group == group { return count + 1 }
        else { return count }
      });
      // choose randomly
      var skip = random() % optionsInGroup
      var food = EatViewController.foods[0]
      for i in 0..<(EatViewController.foods.count) {
        food = EatViewController.foods[i]
        if food.group == group {
          if skip == 0 {
            self.foodIndexByGroup[group] = i
            break
          } else {
            skip -= 1
          }
        }
      }
      return food
    }
  }
  
  func resetFoodGroupBarsFromRecentMeals() {
    let _ = Food.Group.allValues.map{self.updateFoodGroupBar($0)}
  }
  
  func heightConstraintForFoodGroup(group: Food.Group) -> NSLayoutConstraint {
    switch group {
    case .Grain: return self.grainBarHeight
    case .Vegetable: return self.vegetableBarHeight
    case .Fruit: return self.fruitBarHeight
    case .Protein: return self.proteinBarHeight
    case .Dairy: return self.dairyBarHeight
    }
  }
  
  func updateFoodGroupBar(group: Food.Group) {
    let servings = self.servings[group]!
    self.updateFoodGroupBar(group, servings: servings)
  }
  
  func updateFoodGroupBar(group: Food.Group, servings: Int) {
    self.view.layoutIfNeeded()
    UIView.animateWithDuration(0.5) { () -> Void in
      self.heightConstraintForFoodGroup(group).constant = (CGFloat(100) * CGFloat(servings) / CGFloat(group.recommendedServings)) + 60
      self.view.layoutIfNeeded()
    }
  }
  
  class func digestLeastRecentMeal() {
    var meals = EatViewController.meals
    
    if meals.count > 0 {
      meals.removeAtIndex(0)
      saveValuesToDefaults(meals, key: kUserDefaultsMeals)
    }
  }

}

protocol EatViewControllerDelegate {
  func eatViewControllerDidDismiss(vc: EatViewController)
}
