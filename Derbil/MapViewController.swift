//
//  MapViewController.swift
//  Chubbyy
//
//  Created by David Mazza on 2/8/16.
//  Copyright © 2016 Peaking Software LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
  
  @IBOutlet var mapView: MKMapView!
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
//    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
    
    mapView.setUserTrackingMode(.Follow, animated: true)
    mapView.delegate = self
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
    
    dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
      let annotation = MKPointAnnotation()
      annotation.coordinate = self.mapView.centerCoordinate
      annotation.title = "20 mins away"
      
//      mapView.removeAnnotations(mapView.annotations)
      self.mapView.addAnnotation(annotation);
    }
  }
  
  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    
  }
  
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    
  }
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
  }
  
}