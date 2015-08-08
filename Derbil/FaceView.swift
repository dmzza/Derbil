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
    
    var face: Face
    var leftImageView: UIImageView
    var rightImageView: UIImageView
    var mouthImageView: UIImageView

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(face: Face) {
        self.face = face
        self.leftImageView = UIImageView(image: UIImage(named: self.face.imageName(self.face.leftEye)))
        self.rightImageView = UIImageView(image: UIImage(named: self.face.imageName(self.face.rightEye)))
        self.mouthImageView = UIImageView(image: UIImage(named: self.face.imageName(self.face.mouth)))
        super.init(frame: CGRectMake(0, 0, 567, 230))
        self.leftImageView.frame = CGRectMake(0, 0, 162, 230)
        self.mouthImageView.frame = CGRectMake(162, 0, 243, 230)
        self.rightImageView.frame = CGRectMake(405, 0, 162, 230)
        self.addSubview(self.leftImageView)
        self.addSubview(self.rightImageView)
        self.addSubview(self.mouthImageView)
        
    }

}
