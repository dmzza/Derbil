//
//  Food.swift
//  Chubbyy
//
//  Created by David Mazza on 1/21/16.
//  Copyright © 2016 Peaking Software LLC. All rights reserved.
//

import Foundation

struct Food {
  
  enum Group: Int {
    case Grain
    case Vegetable
    case Fruit
    case Protein
    case Dairy
    var recommendedServings: Int {
      // daily values based on a 2200 calorie adult diet
      // http://www.cnpp.usda.gov/sites/default/files/dietary_guidelines_for_americans/MyPlateDailyChecklist_2200cals_Age14plus.pdf
      switch self {
      case Grain: return 7
      case Vegetable: return 3
      case Fruit: return 2
      case Protein: return 6
      case Dairy: return 3
      }
    }
    var icon: String {
      switch self {
      case Grain: return "bread.png"
      case Vegetable: return "eggplant.png"
      case Fruit: return "fruit.png"
      case Protein: return "meal.png"
      case Dairy: return "cheese.png"
      }
    }
  }
  
  enum FatContent: Int {
    case None
    case Lean
    case Moderate
    case Fatty
  }
  
  enum SugarContent: Int {
    case None
    case Low
    case Natural
    case Sweet
  }
  
  let group: Group
  let fat: FatContent
  let sugar: SugarContent
  let name: String
  let icon: String?
  init(group: Group, fat: FatContent, sugar: SugarContent, name: String) {
    self = Food.init(group: group, fat: fat, sugar: sugar, name: name, icon: nil)
  }
  init(group: Group, fat: FatContent, sugar: SugarContent, name: String, icon: String?) {
    self.group = group
    self.fat = fat
    self.sugar = sugar
    self.name = name
    self.icon = icon
  }
  var iconName: String {
    if let name = self.icon {
      return "\(name).png"
    } else {
      return self.group.icon
    }
  }
  
  
}

extension Food: PropertyListReadable {
  func propertyListRepresentation() -> NSDictionary {
    let representation:[String:AnyObject] = [
      "group": self.group.rawValue,
      "fat": self.fat.rawValue,
      "sugar": self.sugar.rawValue,
      "name": self.name,
      "iconName": self.iconName
    ]
    return representation
  }
  
  init?(propertyListRepresentation:NSDictionary?) {
    guard let values = propertyListRepresentation else {return nil}
    if let group = values["group"] as? Int,
      fat = values["y"] as? Int,
      sugar = values["z"] as? Int,
      name = values["name"] as? String,
      iconName = values["iconName"] as? String {
        self.group = Group(rawValue: group)!
        self.fat = FatContent(rawValue: fat)!
        self.sugar = SugarContent(rawValue: sugar)!
        self.name = name
        if self.group.icon != iconName {
          self.icon = iconName.componentsSeparatedByString(".").first
        } else {
          self.icon = nil
        }
    } else {
      return nil
    }
  }
}

