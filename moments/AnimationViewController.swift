//
//  AnimationViewController.swift
//  moments
//
//  Created by Pak on 10/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
import Mapbox

class AnimationViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet weak var btn: UIButton!
    @IBAction func btnTapped(sender: UIButton) {
        
        
      
        /*
         STEP 1: Get a login URL from SPAuth and open it in Safari.
         */

        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
        
        
//        let hello = MGLPointAnnotation()
//       
//        hello.title = "Hello world!"
//        hello.subtitle = "Welcome to my marker"
//        hello.coordinate = CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407)
//        
//        
//        self.mapView.addAnnotation(hello)
//        
//        
//        
//        
//        UIView.animateWithDuration(3, delay: 2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//             //hello.coordinate = CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407)
//            }, completion: nil)

    }
    
    var mapView = MGLMapView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407), zoomLevel: 12, animated: false)
        view.addSubview(mapView)
        
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        view.sendSubviewToBack(mapView)
        
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}