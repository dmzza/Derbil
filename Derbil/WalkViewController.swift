//
//  WalkViewController.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

protocol WalkViewControllerDelegate {
    func didComplete(controller: WalkViewController, elapsedTime: NSTimeInterval)
}

class WalkViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var faceContainer: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    var elapsedTime: NSTimeInterval = 0
    var timer: NSTimer!
    var faceView: FaceView?
    var delegate: WalkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.faceView == nil {
            let face: Face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Tongue, Face.Part.Mouth),
                leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
                rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
            self.faceView = FaceView(face: face, frame: self.faceContainer.bounds)
            self.faceContainer.addSubview(self.faceView!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loop(view: UIView) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
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
        self.delegate?.didComplete(self, elapsedTime: self.elapsedTime)
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
