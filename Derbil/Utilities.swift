//
//  Utilities.swift
//  Derbil
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