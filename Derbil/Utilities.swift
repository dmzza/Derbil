//
//  Utilities.swift
//  Chubbyy
//
//  Created by dmazza on 8/8/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func stringOfJSONFile(named: String) -> String? {
  let filename = named.stringByReplacingOccurrencesOfString(".json", withString: "")
  if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
    do {
      let jsonString = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
      return jsonString as String
    } catch {
      NSLog("\(filename).json not readable")
      return nil
    }
} else {
  NSLog("\(filename).json not found")
}
  return nil
}
