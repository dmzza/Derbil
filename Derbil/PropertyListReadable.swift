//
//  PropertyListReadable.swift
//  Chubbyy
//
//  Created by David Mazza on 1/21/16.
//  Copyright © 2016 Peaking Software LLC. All rights reserved.
//  Taken from: https://github.com/SonoPlot/PropertyListSwiftPlayground
//

import Foundation

// MARK: -
// MARK: Property list conversion protocol

protocol PropertyListReadable {
  func propertyListRepresentation() -> NSDictionary
  init?(propertyListRepresentation:NSDictionary?)
}

func extractValuesFromPropertyListArray<T:PropertyListReadable>(propertyListArray:[AnyObject]?) -> [T] {
  guard let encodedArray = propertyListArray else {return []}
  return encodedArray.map{$0 as? NSDictionary}.flatMap{T(propertyListRepresentation:$0)}
}

func saveValuesToDefaults<T:PropertyListReadable>(newValues:[T], key:String) {
  let encodedValues = newValues.map{$0.propertyListRepresentation()}
  NSUserDefaults.standardUserDefaults().setObject(encodedValues, forKey:key)
}
