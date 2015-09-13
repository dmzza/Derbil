//
//  InterfaceController.swift
//  Chubbyy WatchKit Extension
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var actionButton: WKInterfaceButton!
    @IBOutlet var pauseGroup: WKInterfaceGroup!
    
    @IBOutlet var actionNameLabel: WKInterfaceLabel!
    @IBOutlet var walkTimer: WKInterfaceTimer!
    var walking: Bool = false {
        didSet {
            if walking {
                actionButton.setHidden(false)
                pauseGroup.setHidden(true)
                actionNameLabel.setHidden(true)
                walkTimer.setHidden(false)
                walkTimer.start()
            } else {
                walkTimer.stop()
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didAct() {
        if walking {
            // Pause
            actionButton.setHidden(true)
            pauseGroup.setHidden(false)
            walking = false
        } else {
            // Start
            walkTimer.setDate(NSDate())
            walking = true
        }
    }

    @IBAction func resume() {
        walking = true
    }
    
    @IBAction func end() {
        actionButton.setHidden(false)
        pauseGroup.setHidden(true)
        actionNameLabel.setHidden(false)
        walkTimer.setHidden(true)
        walking = false
    }
    

}
