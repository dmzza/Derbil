//
//  ViewController.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WalkViewControllerDelegate {

    @IBOutlet weak var faceContainer: UIView!
    var faceView: FaceView?
    let happyWalkThreshold: NSTimeInterval = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.faceView == nil) {
            let face: Face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
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
    
    func smile(duration: NSTimeInterval) {
        if let view: FaceView = self.faceView {
            let face: Face = self.faceView!.face
            view.face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Smiling, Face.Part.Mouth),
                leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
                rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
            delay(duration) { () -> () in
                view.face = face
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WalkViewControllerSegue" {
            let vc: WalkViewController = (segue.destinationViewController as! UINavigationController).topViewController as! WalkViewController
            vc.delegate = self
        }
    }

    func didComplete(controller: WalkViewController, elapsedTime: NSTimeInterval) {
        if elapsedTime >= happyWalkThreshold {
            self.smile(elapsedTime / 10)
        }
    }
}
