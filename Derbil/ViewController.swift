//
//  ViewController.swift
//  Derbil
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var faceContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let face: Face = Face(
            mouth: Face.Name.MouthName(Face.Mouth.Smiling, Face.Part.Mouth),
            leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
            rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
        let faceView: FaceView = FaceView(face: face)
        self.faceContainer.addSubview(faceView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

