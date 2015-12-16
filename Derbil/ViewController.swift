//
//  ViewController.swift
//  Chubbyy
//
//  Created by dmazza on 8/2/15.
//  Copyright © 2015 Peaking Software LLC. All rights reserved.
//

import UIKit

let kUserDefaultsTodaysWalkCount = "TodaysWalkCount"
let kUserDefaultsHeadColor = "HeadColor"
let kHappyWalkThreshold: NSTimeInterval = 120
let kPressHeadDuration: NSTimeInterval = 0.08

class ViewController: UIViewController, WalkViewControllerDelegate, UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate {
  
  @IBOutlet weak var faceContainer: UIView!
  var faceView: FaceView?
  @IBOutlet var speechBubbleLabel: UILabel!
  @IBOutlet var responseBubbleLabel: UILabel!
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
  let userDefaults = NSUserDefaults.standardUserDefaults()
  
  @IBOutlet var headView: UIImageView!
  @IBOutlet var firstHeart: UIImageView!
  @IBOutlet var secondHeart: UIImageView!
  @IBOutlet var thirdHeart: UIImageView!
  
  @IBOutlet var loveButton: UIButton!
  @IBOutlet var headPressRecognizer: UILongPressGestureRecognizer!
  @IBOutlet var colorPanRecognizer: UIPanGestureRecognizer!
  
  
  let walksPerDay = 4
  var walks: Int = 0 {
    didSet {
      self.firstHeart.hidden = walks < 1
      self.secondHeart.hidden = walks < 2
      self.thirdHeart.hidden = walks < 3
    }
  }
  
  let notificationTitle = "Chubbyy needs love"
  let morningNotificationBody = "🌞"
  let morningNotificationThought = "Wake up! I need to pee, take me outside."
  let afternoonNotificationBody = "😋"
  let afternoonNotificationThought = "That was a big lunch. I need to pee again."
  let eveningNotificationBody = "🌝"
  let eveningNotificationThought = "Take me for a walk before bed."
  let warningNotificationBody = "😖"
  let firstWarningNotificationThought = "Okay, seriously I need to go outside."
  let finalWarningNotificationThought = "If we wait any longer there is gonna be trouble!"
  let accidentNotificationThought = "Oops, I couldn't hold it any longer."
  let secondsPerDay: Double = 60 * 60 * 24
  let morningNotificationTime: NSTimeInterval = 9.0 * 3600
  let afternoonNotificationTime: NSTimeInterval = 15.0 * 3600
  let eveningNotificationTime: NSTimeInterval = 21.0 * 3600
  let firstWarningInterval: NSTimeInterval = 0.5 * 3600;
  let finalWarningInterval: NSTimeInterval = 1.5 * 3600;
  let accidentInterval: NSTimeInterval = 1.75 * 3600;
  
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
        self.userDefaults.setInteger(0, forKey: kUserDefaultsTodaysWalkCount)
    }
    
    self.walks = userDefaults.integerForKey(kUserDefaultsTodaysWalkCount)
    self.animator = UIDynamicAnimator(referenceView: self.view)
    self.animator!.delegate = self
    self.revertToSavedHeadColor()
    self.headPressRecognizer.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (self.headSnapBehavior == nil) {
      self.headSnapBehavior = UISnapBehavior(item: self.headView, snapToPoint: CGPointMake(self.headView.frame.midX, self.headView.frame.midY))
      
      self.animator!.addBehavior(self.headSnapBehavior!)
    }
  }
  
  func scheduleNotifications() {
    let morningNotification = self.notification(morningNotificationTime, body: morningNotificationBody, title: notificationTitle, thought:morningNotificationThought)
    let afternoonNotification = self.notification(afternoonNotificationTime, body: afternoonNotificationBody, title: notificationTitle, thought:morningNotificationThought)
    let eveningNotification = self.notification(eveningNotificationTime, body: eveningNotificationBody, title: notificationTitle, thought:morningNotificationThought)
    var secondsToSoonestNotification = secondsPerDay
    let now = NSDate().timeIntervalSinceReferenceDate
    //        let soonestNotification: NSTimeInterval
    
    var interval = morningNotification.fireDate!.timeIntervalSinceReferenceDate - now
    if interval < secondsToSoonestNotification {
      secondsToSoonestNotification = interval
    }
    interval = afternoonNotification.fireDate!.timeIntervalSinceReferenceDate - now
    if interval < secondsToSoonestNotification {
      secondsToSoonestNotification = interval
    }
    interval = eveningNotification.fireDate!.timeIntervalSinceReferenceDate - now
    if interval < secondsToSoonestNotification {
      secondsToSoonestNotification = interval
    }
    //        soonestNotification = self.secondsSinceMidnight + secondsToSoonestNotification
    
    //        let firstWarningNotification = self.notification(soonestNotification + firstWarningInterval, body: warningNotificationBody, title: notificationTitle, thought: firstWarningNotificationThought)
    //        let finalWarningNotification = self.notification(soonestNotification + finalWarningInterval, body: warningNotificationBody, title: notificationTitle, thought: finalWarningNotificationThought)
    //        let accidentNotification = self.notification(soonestNotification + accidentInterval, body: warningNotificationBody, title: notificationTitle, thought: accidentNotificationThought)
    
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    UIApplication.sharedApplication().scheduleLocalNotification(morningNotification)
    UIApplication.sharedApplication().scheduleLocalNotification(afternoonNotification)
    UIApplication.sharedApplication().scheduleLocalNotification(eveningNotification)
    //        UIApplication.sharedApplication().scheduleLocalNotification(firstWarningNotification)
    //        UIApplication.sharedApplication().scheduleLocalNotification(finalWarningNotification)
    //        UIApplication.sharedApplication().scheduleLocalNotification(accidentNotification)
  }
  
  func notification(intervalFromMidnight: NSTimeInterval, body: String, title: String, thought: String) -> UILocalNotification {
    let note = UILocalNotification()
    var intervalFromNow = intervalFromMidnight - self.secondsSinceMidnight
    
    note.alertBody = body
    note.alertTitle = title
    note.userInfo = ["thought": thought]
    note.category = "myCategory"
    if intervalFromNow < 0 {
      intervalFromNow += secondsPerDay // bump it out to tomorrow
    }
    note.fireDate = NSDate(timeIntervalSinceNow: intervalFromNow)
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
  
  @IBAction func changeColor(sender: UIPanGestureRecognizer) {
    let deltaY = sender.translationInView(self.view).y / self.view.bounds.size.height
    var sat: CGFloat = 0.0
    var bri: CGFloat = 0.0
    self.headColor.getHue(nil, saturation: &sat, brightness: &bri, alpha: nil)
    let hue = (self.hueStartingPoint + deltaY + 1.0) % 1.0
    let translateY = sender.translationInView(self.view).y / 5
    let translateX = sender.translationInView(self.view).x / 2
    switch sender.state {
    case .Changed:
      self.headColor = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1.0)
      self.moveHead(translateX, y: translateY)
      break
    case .Cancelled:
      self.revertToSavedHeadColor()
      self.releaseHead()
      break
    case .Ended:
      self.userDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.headColor), forKey: kUserDefaultsHeadColor)
      self.releaseHead()
      break
    case .Possible:
      print("possible")
      break
    case .Began:
      self.panStartingPoint = sender.locationInView(nil)
      self.headColor.getHue(&self.hueStartingPoint, saturation: nil, brightness: nil, alpha: nil)
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
    // reserved for future use
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
  }
  
  var secondsSinceMidnight: NSTimeInterval {
    return (NSDate().timeIntervalSinceReferenceDate % secondsPerDay) + Double(NSTimeZone.localTimeZone().secondsFromGMT)
  }
  
  func revertToSavedHeadColor() {
    if let savedHeadColor: NSData = userDefaults.objectForKey(kUserDefaultsHeadColor) as? NSData {
      self.headColor = NSKeyedUnarchiver.unarchiveObjectWithData(savedHeadColor) as! UIColor
    }
  }
  
  @IBAction func didTripleTap(sender: UITapGestureRecognizer) {
    let secondsSinceMidnight = (NSDate().timeIntervalSinceReferenceDate % secondsPerDay) + Double(NSTimeZone(abbreviation: "PST")!.secondsFromGMT)
    let instaNote: UILocalNotification = self.notification(secondsSinceMidnight + 5, body: "😖", title: notificationTitle, thought: "Hello")
    UIApplication.sharedApplication().scheduleLocalNotification(instaNote)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "WalkViewControllerSegue" {
      let vc: WalkViewController = (segue.destinationViewController as! UINavigationController).topViewController as! WalkViewController
      vc.delegate = self
    }
  }
  
  func didComplete(controller: WalkViewController, elapsedTime: NSTimeInterval) {
    if elapsedTime >= kHappyWalkThreshold {
      self.smile(elapsedTime / 10)
      let userDefaults = NSUserDefaults.standardUserDefaults()
      let currentWalks: Int = userDefaults.integerForKey(kUserDefaultsWalkCount)
      let todaysWalks: Int = userDefaults.integerForKey(kUserDefaultsTodaysWalkCount)
      
      self.walks = todaysWalks + 1
      userDefaults.setInteger(currentWalks + 1, forKey: kUserDefaultsWalkCount)
      userDefaults.setInteger(self.walks, forKey: kUserDefaultsTodaysWalkCount)
      
    }
  }
  
  // mark - UIGestureRecognizerDelegate
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if otherGestureRecognizer is UIPanGestureRecognizer {
      return true
    }
    return false
  }
  
  // mark - UIDynamicAnimatorDelegate
  
  func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
    if !self.isSleeping {
      self.faceView!.face = Face(
        mouth: Face.Name.MouthName(Face.Mouth.Puppy, Face.Part.Mouth),
        leftEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Left),
        rightEye: Face.Name.EyeName(Face.Eye.Normal, Face.Part.Right))
    }
  }
}
