//
//  FaceView.swift
//  Chubbyy
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
        case Frowning = "frowning"
        case Sad = "sad"
        case Smiling = "smiling"
        case Laughing = "laughing"
        case Puppy = "puppy"
        case Tongue = "tongue"
        case Tired = "tired"
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
    let mouthRelativeWidth: CGFloat = 243.0/567.0
    var pattern: () -> () = { () -> () in }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(face: Face, frame: CGRect) {
        let eyeRelativeWidth: CGFloat = (1.0 - self.mouthRelativeWidth) / 2.0
        self.leftImageView = UIImageView(frame: CGRectMake(
            0,
            0,
            frame.size.width * eyeRelativeWidth,
            frame.size.height))
        self.rightImageView = UIImageView(frame: CGRectMake(
            frame.size.width * eyeRelativeWidth + frame.size.width * mouthRelativeWidth,
            0,
            frame.size.width * eyeRelativeWidth,
            frame.size.height))
        self.mouthImageView = UIImageView(frame: CGRectMake(
            frame.size.width * eyeRelativeWidth,
            0,
            frame.size.width * self.mouthRelativeWidth,
            frame.size.height))
        self.face = face
        super.init(frame: frame)
        self.addSubview(self.leftImageView)
        self.addSubview(self.rightImageView)
        self.addSubview(self.mouthImageView)
        self.pattern = { () -> () in
            delay(0.1, closure: { () -> () in
                self.pattern()
            })
        }
        self.pattern()
        self.blink()
    }

    func blink() {
        self.pattern = { () -> () in
            let face = self.face
            self.face = Face(
                mouth: face.mouth,
                leftEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Left),
                rightEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Right))
            delay(0.15) { () -> () in
                self.face = face
            }
            delay(3.5) { () -> () in
                self.pattern()
            }
        }
    }
    
    func snore(animator: UIDynamicAnimator?, targetView: UIView?) {
        self.pattern = { () -> () in
            let face = self.face
            self.face = Face(
                mouth: Face.Name.MouthName(Face.Mouth.Frowning, Face.Part.Mouth),
                leftEye: face.leftEye,
                rightEye: face.rightEye)
            if let anim = animator, let view = targetView {
                self.giveHeart(anim, endPoint: view.center);
            }
            delay(1.5) { () -> () in
                self.face = face
            }
            delay(5.5) { () -> () in
                self.pattern()
            }
        }
    }
    
    func giveHeart(animator: UIDynamicAnimator, endPoint: CGPoint) {
        let heart: UIImageView = UIImageView(image: UIImage(named: "tiny-heart"))
        heart.frame = CGRect(origin: self.mouthImageView.center, size: CGSize(width: 44.0, height: 44.0))
        heart.tintColor = UIColor.redColor()
        self.addSubview(heart)
        let behavior: FlyingHeartBehavior = FlyingHeartBehavior(item: heart, endPoint: endPoint)
        UIView.animateWithDuration(2.0) { () -> Void in
            heart.transform = CGAffineTransformMakeScale(0.5, 0.5)
            heart.alpha = 0.0
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            heart.removeFromSuperview()
        }
        animator.addBehavior(behavior)
    }
}
