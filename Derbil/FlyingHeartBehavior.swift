//
//  FlyingHeartBehavior.swift
//  Chubbyy
//
//  Created by David Mazza on 9/1/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

class FlyingHeartBehavior: UIDynamicBehavior {
    
    init(item: UIDynamicItem, endPoint: CGPoint) {
        super.init()
        
        let snapBehavior: UISnapBehavior = UISnapBehavior(item: item, snapToPoint: endPoint)
        let pushBehavior: UIPushBehavior = UIPushBehavior(items: [item], mode: UIPushBehaviorMode.Instantaneous)
        let itemBehavior: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [item])
        
        itemBehavior.resistance = 50.0
        itemBehavior.density = 0.1
        snapBehavior.damping = 0.65
        pushBehavior.setAngle(CGFloat(arc4random()) / 6.24, magnitude: 1.8)
        
        self.addChildBehavior(itemBehavior)
        self.addChildBehavior(pushBehavior)
        self.addChildBehavior(snapBehavior)
        
        
    }

}
