//
//  WalkViewController.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

class WalkViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var timerLabel: UILabel!
    var elapsedTime: NSTimeInterval = 0
    var timer: NSTimer!
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        if (self) {
//            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector(start()), userInfo: nil, repeats: true)
//        }
//        return self;
//    }

//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    func tick() {
        self.elapsedTime++
        let formatter: NSDateFormatter = NSDateFormatter()
            
        formatter.dateFormat = "m:ss";
        
        self.timerLabel.text = formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: self.elapsedTime))
    }
    
    @IBAction func close(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
