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
        let rightFoot: UIView = UIView(frame: CGRectMake(0, self.view.bounds.size.height - 20, 60, 10))
        let leftFoot: UIView = UIView(frame: CGRectMake(0, self.view.bounds.size.height - 80, 60, 10))
        
        rightFoot.backgroundColor = UIColor.blackColor()
        leftFoot.backgroundColor = UIColor.blackColor()
        rightFoot.alpha = 0.0
        leftFoot.alpha = 0.0
        self.view.addSubview(rightFoot)
        self.view.addSubview(leftFoot)
        
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            self.loop(rightFoot)
        }
        dispatch_after(400000, dispatch_get_main_queue()) { () -> Void in
            self.loop(leftFoot)
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loop(view: UIView) {
        
        UIView.animateWithDuration(1.9, animations: { () -> Void in
            view.transform = CGAffineTransformMakeTranslation(self.view.bounds.width, 0)
            view.alpha = 1.0
            }) { (finished: Bool) -> Void in
                view.transform = CGAffineTransformMakeTranslation(-1 * view.bounds.width, 0)
                self.loop(view)
        }
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
