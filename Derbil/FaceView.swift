//
//  FaceView.swift
//  Derbil
//
//  Created by dmazza on 8/8/15.
//  Copyright (c) 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

struct Face {
    enum Eye: String {
        case Normal = "normal"
        case Closed = "closed"
        case Angry = "angry"
        case Sad = "sad"
    }
    
    enum Mouth: String {
        case Angry = "angry"
        case Sad = "sad"
        case Smiling = "smiling"
        case Laughing = "laughing"
        case Puppy = "puppy"
        case Tongue = "tongue"
    }
    
    enum Part: String {
        case Left = "left-eye"
        case Right = "right-eye"
        case Mouth = "mouth"
    }

    enum Name {
        case EyeName(Eye, Part)
        case MouthName(Mouth, Part)
    }

    var mouth: Name
    var leftEye: Name
    var rightEye: Name

    func imageName(name: Name) -> String {
        switch name {
            case let .EyeName(eye, part):
                return "\(eye.rawValue)-\(part.rawValue)"
            case let .MouthName(mouth, part):
                return "\(mouth.rawValue)-\(part.rawValue)"
        }
    }

}



class FaceView: UIView {
    
    var face: Face {
        didSet {
            self.leftImageView.image = UIImage(named: self.face.imageName(self.face.leftEye))
            self.rightImageView.image = UIImage(named: self.face.imageName(self.face.rightEye))
            self.mouthImageView.image = UIImage(named: self.face.imageName(self.face.mouth))
        }
    }
    var leftImageView: UIImageView
    var rightImageView: UIImageView
    var mouthImageView: UIImageView

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(face: Face) {
        self.leftImageView = UIImageView(frame: CGRectMake(0, 0, 162, 230))
        self.rightImageView = UIImageView(frame: CGRectMake(405, 0, 162, 230))
        self.mouthImageView = UIImageView(frame: CGRectMake(162, 0, 243, 230))
        self.face = face
        super.init(frame: CGRectMake(0, 0, 567, 230))
        self.addSubview(self.leftImageView)
        self.addSubview(self.rightImageView)
        self.addSubview(self.mouthImageView)
        self.blink()
    }

    func blink() {
        let face = self.face
        self.face = Face(
            mouth: face.mouth,
            leftEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Left),
            rightEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Right))
        delay(0.15) { () -> () in
            self.face = face
        }
        delay(3.5) { () -> () in
            self.blink()
        }
    }
}
