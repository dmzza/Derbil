//
//  ViewController.swift
//  Chubbyy
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsHeadColor = "HeadColor"
let kHappyWalkThreshold: NSTimeInterval = 120
let kPressHeadDuration: NSTimeInterval = 0.08

class ViewController: UIViewController, EatViewControllerDelegate, UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate, DialogManagerDelegate {

  @IBOutlet weak var faceContainer: UIView!
  var faceView: FaceView?
  @IBOutlet var speechBubble: UIView!
  @IBOutlet var responseBubble: UIView!
  @IBOutlet var speechBubbleLabel: UILabel!
  @IBOutlet var responseBubbleLabel: UILabel!
  @IBOutlet var responseBubbleImage: UIImageView!
  @IBOutlet var eatButton: UIButton!

  var animator: UIDynamicAnimator?
  var pushHeadBehavior: UIPushBehavior?
  var headSnapBehavior: UISnapBehavior?
  var headColor: UIColor = UIColor(hue: 0.706, saturation: 0.41, brightness: 0.87, alpha: 1.0) {
    didSet {
      self.headView.tintColor = headColor
    }
  }
  var isSleeping = false {
    didSet {
      if isSleeping {
        self.faceView!.face = Face(
          mouth: Face.Name.MouthName(Face.Mouth.Smiling, Face.Part.Mouth),
          leftEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Left),
          rightEye: Face.Name.EyeName(Face.Eye.Closed, Face.Part.Right))
        self.faceView!.snore(self.animator!, targetView: self.loveButton)
      } else {
        self.faceView!.face = Face(
          mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
          leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
          rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
        self.faceView!.blink()
      }
    }
  }
  var panStartingPoint = CGPoint(x: 0, y: 0)
  var hueStartingPoint:CGFloat = 0.0
  let bubbleFadeInDuration = 1.0
  let userDefaults = NSUserDefaults.standardUserDefaults()

  var dialogManager: DialogManager?
  var responseCompletionBlock: ((didRespond: Bool, response: Any?) -> ())?
  var responseSentence: Sentence?
  var speechCompletionBlock: ((didSpeak: Bool) -> ())?
  var speechSentence: Sentence?

  @IBOutlet var headView: UIImageView!
  @IBOutlet var loveButton: UIButton!
  @IBOutlet var headPressRecognizer: UILongPressGestureRecognizer!
  @IBOutlet var colorPanRecognizer: UIPanGestureRecognizer!

  let notificationTitle = "Chubbyy needs love"
  let morningNotificationBody = "🌞"
  let morningNotificationThought = "Wake up! I need to pee, take me outside."
  let afternoonNotificationBody = "😋"
  let afternoonNotificationThought = "That was a big lunch. I need to pee again."
  let eveningNotificationBody = "🌝"
  let eveningNotificationThought = "Take me for a walk before bed."
  let morningNotificationTime = NSDate().change(hour: 9, minute: 0)
  let afternoonNotificationTime = NSDate().change(hour: 15, minute: 0)
  let eveningNotificationTime = NSDate().change(hour: 21, minute: 0)

  override func awakeFromNib() {
    super.awakeFromNib()

    let face: Face = Face(
      mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
      leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
      rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
    let center = CGPointMake(self.view.frame.midX, self.view.frame.midY)

    self.faceView = FaceView(face: face, frame: self.faceContainer.bounds)
    self.faceContainer.addSubview(self.faceView!)

    let faceSnapBehavior = UISnapBehavior(item: self.faceView!, snapToPoint: center)

    self.pushHeadBehavior = UIPushBehavior(items: [self.faceView!, self.headView], mode: .Continuous)
    self.pushHeadBehavior!.pushDirection = CGVectorMake(0, 0)
    self.pushHeadBehavior!.magnitude = 0
    self.animator!.addBehavior(faceSnapBehavior)
    self.animator!.addBehavior(self.pushHeadBehavior!)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.scheduleNotifications()
    NSNotificationCenter.defaultCenter().addObserverForName(kInAppNotificationReceived,
      object: nil,
      queue: NSOperationQueue.mainQueue(),
      usingBlock: { (note) -> Void in
        if let userInfo = (((note.userInfo! as Dictionary)["notification"])! as! UILocalNotification).userInfo {
          if let thought = userInfo["thought"] as? String {
            self.speak(thought)
          }
        }
    })

    NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameNewDayBegan,
      object: nil,
      queue: NSOperationQueue.mainQueue()) { (note) -> Void in
        EatViewController.digestLeastRecentMeal()
    }

    NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameLuckyNumberReceived,
        object: nil,
        queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            let luckyNumber = ((note.userInfo! as Dictionary)[kNotificationUserInfoKeyLuckyNumber])! as! UInt
            // do nothing yet
    }

    NSNotificationCenter.defaultCenter().addObserverForName(kNotificationNameDeviceShaken,
        object: nil,
        queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("EatViewController") as! EatViewController
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
    }

    self.animator = UIDynamicAnimator(referenceView: self.view)
    self.animator!.delegate = self
    self.revertToSavedHeadColor()
    self.headPressRecognizer.delegate = self

    self.speechBubble.alpha = 0.0
    self.responseBubble.alpha = 0.0

    self.dialogManager = DialogManager(delegate: self)

    self.eatButton.layer.cornerRadius = 23.0
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (self.headSnapBehavior == nil) {
      self.headSnapBehavior = UISnapBehavior(item: self.headView, snapToPoint: CGPointMake(self.headView.frame.midX, self.headView.frame.midY))

      self.animator!.addBehavior(self.headSnapBehavior!)
      self.responseBubbleImage.image = flippedBubbleImage()
    }
  }

  func scheduleNotifications() {
    let morningNotification = self.notification(morningNotificationTime, body: morningNotificationBody, title: notificationTitle, thought:morningNotificationThought)
    let afternoonNotification = self.notification(afternoonNotificationTime, body: afternoonNotificationBody, title: notificationTitle, thought:morningNotificationThought)
    let eveningNotification = self.notification(eveningNotificationTime, body: eveningNotificationBody, title: notificationTitle, thought:morningNotificationThought)

    UIApplication.sharedApplication().cancelAllLocalNotifications()
    UIApplication.sharedApplication().scheduleLocalNotification(morningNotification)
    UIApplication.sharedApplication().scheduleLocalNotification(afternoonNotification)
    UIApplication.sharedApplication().scheduleLocalNotification(eveningNotification)
  }

  func notification(timeOfDay: NSDate, body: String, title: String, thought: String) -> UILocalNotification {
    let note = UILocalNotification()
    let now = NSDate()

    note.alertBody = body
    note.alertTitle = title
    note.userInfo = ["thought": thought]
    note.category = "myCategory"
    note.fireDate = timeOfDay
    if timeOfDay < now {
      note.fireDate = timeOfDay + 1.day
    }
    note.timeZone = NSTimeZone(abbreviation: "PST")
    print("\(note.fireDate?.description)")
    return note
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

  func speak(thoughts: String) {
    self.speechBubbleLabel.text = thoughts
  }


  @IBAction func sendResponse(sender: AnyObject) {
    if let completion = self.responseCompletionBlock {
      let slideUp = CGAffineTransformMakeTranslation(0, -100)
      UIView.animateWithDuration(bubbleFadeInDuration, animations: { () -> Void in
        self.speechBubble.alpha = 0.0
        self.speechBubble.transform = slideUp
        self.responseBubble.transform = slideUp
        }, completion: { (Bool) -> Void in
          if let sentence = self.responseSentence {
            if sentence.text!.containsString("notifications") {
              UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
            }
            if let type = sentence.responseType {
              switch type {
              case .Boolean: completion(didRespond: true, response: true)
              case .Number: completion(didRespond: true, response: 420)
              case .String: completion(didRespond: true, response: "Solis")
              }
            } else {
              completion(didRespond: true, response: nil)
            }
          }
          self.responseCompletionBlock = nil
          self.responseSentence = nil
      })

    }
  }

  @IBAction func changeColor(sender: UIPanGestureRecognizer) {
    let translateY = sender.translationInView(self.view).y / 5
    let translateX = sender.translationInView(self.view).x / 2
    switch sender.state {
    case .Changed:
      self.moveHead(translateX, y: translateY)
      break
    case .Cancelled:
      self.releaseHead()
      break
    case .Ended:
      self.releaseHead()
      break
    case .Possible:
      print("possible")
      break
    case .Began:
      self.panStartingPoint = sender.locationInView(nil)
      self.pressHead()
      break
    case .Failed:
      print("failed")
      break
    }
  }

  @IBAction func eatMeal(sender: AnyObject) {
    if self.isSleeping {
      self.pressHead()
      self.releaseHead()
      return
    }
    self.faceView!.face = Face(
      mouth: Face.Name.MouthName(Face.Mouth.Laughing, Face.Part.Mouth),
      leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
      rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))

    for i in 1...10 {
      NSTimer.scheduledTimerWithTimeInterval(0.05 * Double(i), target: self, selector: "giveHeart", userInfo: nil, repeats: false)
    }
  }

  @IBAction func tapHead(sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .Began:
      self.pressHead()
      break
    case .Ended:
      self.releaseHead()
      break
    case .Cancelled:
      self.releaseHead()
      break
    default:
      break
    }
  }

  @IBAction func tapBackground(sender: UITapGestureRecognizer) {
    switch sender.state {
    case .Ended:
      self.giveHeartFromOrigin(sender.locationInView(self.view))
      break
    default:
      break
    }
  }

  func pressHead() {
    if let completion = self.speechCompletionBlock {
      completion(didSpeak: true)
      self.speechCompletionBlock = nil
      self.speechSentence = nil
    } else {
      UIView.animateWithDuration(bubbleFadeInDuration, animations: { () -> Void in
        self.speechBubble.alpha = 0.0
        self.speechBubble.transform = CGAffineTransformMakeTranslation(0, -100)
      })
    }
  }

  func moveHead(x: CGFloat, y: CGFloat) {
    self.pushHeadBehavior!.pushDirection = CGVector(dx: x, dy: y)
    self.pushHeadBehavior!.magnitude = abs(x + y)
  }

  func releaseHead() {
    self.pushHeadBehavior!.pushDirection = CGVectorMake(0, 0)
    self.pushHeadBehavior!.magnitude = 0
  }

  func giveHeart() {
    let randomStartingPoint = CGPointMake(CGFloat(arc4random()) % 6000.0 - 3000.0, CGFloat(arc4random()) % 10000.0 - 5000.0)
    self.giveHeartFromOrigin(randomStartingPoint)
  }

  func giveHeartFromOrigin(origin: CGPoint) {
    let heart: UIImageView = UIImageView(image: UIImage(named: "tiny-heart"))

    heart.frame = CGRect(origin: origin, size: self.loveButton.bounds.size)
    heart.tintColor = UIColor.redColor()
    self.view.addSubview(heart)
    let behavior: FlyingHeartBehavior = FlyingHeartBehavior(item: heart, endPoint: self.loveButton.center)
    UIView.animateWithDuration(2.0, animations: { () -> Void in
      heart.transform = CGAffineTransformMakeScale(0.5, 0.5)
      }) { (finished) -> Void in
        self.animator!.removeBehavior(behavior)
    }

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      heart.removeFromSuperview()
    }
    self.animator!.addBehavior(behavior)

    if let completion = self.speechCompletionBlock {
      completion(didSpeak: true)
      self.speechCompletionBlock = nil
      self.speechSentence = nil
    }
  }

  func revertToSavedHeadColor() {
    if let savedHeadColor: NSData = userDefaults.objectForKey(kUserDefaultsHeadColor) as? NSData {
      self.headColor = NSKeyedUnarchiver.unarchiveObjectWithData(savedHeadColor) as! UIColor
    } else {
      self.headColor = self.headColor.copy() as! UIColor
    }
  }

  @IBAction func didTripleTap(sender: UITapGestureRecognizer) {
    let instaNote: UILocalNotification = self.notification(NSDate() + 5.seconds, body: "😖", title: notificationTitle, thought: "Hello")
    UIApplication.sharedApplication().scheduleLocalNotification(instaNote)
  }

  // MARK: Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let modalVC = segue.destinationViewController as? EatViewController {
      modalVC.delegate = self
    }
  }

  // MARK: EatViewControllerDelegate

  func eatViewControllerDidDismiss(vc: EatViewController) {
    self.dismissViewControllerAnimated(true) { () -> Void in
      self.giveHeart()
    }
  }

  // MARK: UIGestureRecognizerDelegate

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if otherGestureRecognizer is UIPanGestureRecognizer {
      return true
    }
    return false
  }

  // MARK: UIDynamicAnimatorDelegate

  func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
    if !self.isSleeping {
      self.faceView!.face = Face(
        mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
        leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
        rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
    }
  }

  // MARK: DialogManagerDelegate

  func dialogManager(manager: DialogManager, wantsChubbyyToSpeak sentence: Sentence, completion: (didSpeak: Bool) -> ()) {
    self.speechBubbleLabel.text = sentence.text
    self.speechBubble.transform = CGAffineTransformMakeTranslation(0.0, 100.0)
    self.speechBubble.alpha = 0.0
    UIView.animateWithDuration(bubbleFadeInDuration, animations: { () -> Void in
      self.responseBubble.alpha = 0.0
      self.speechBubble.alpha = 1.0
      self.speechBubble.transform = CGAffineTransformIdentity
      }) { (Bool) -> Void in
        self.speechCompletionBlock = completion
        self.speechSentence = sentence
    }
  }

  func dialogManager(manager: DialogManager, wantsUserToRespond sentence: Sentence, completion: (didRespond: Bool, response: Any?) -> ()) {
    var sentenceText = sentence.text!
    if sentence.responseType == ResponseType.Number {
      sentenceText.replaceRange(placeholderRange(sentenceText), with: "420")
    } else if sentence.responseType == ResponseType.String {
      sentenceText.replaceRange(placeholderRange(sentenceText), with: "Solis")
    }
    self.responseBubbleLabel.text = sentenceText
    self.responseBubble.transform = CGAffineTransformMakeTranslation(0.0, 100.0)
    UIView.animateWithDuration(bubbleFadeInDuration, animations: { () -> Void in
      self.responseBubble.alpha = 1.0
      self.responseBubble.transform = CGAffineTransformIdentity;
      }) { (Bool) -> Void in
        self.responseCompletionBlock = completion
        self.responseSentence = sentence
    }
  }
}
