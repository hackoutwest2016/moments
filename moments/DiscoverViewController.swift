//
//  MapViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
// Discover new songs on a map view

import UIKit
import Mapbox



class DiscoverViewController: UIViewController ,MGLMapViewDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    
    var mapView = MGLMapView()
    
    var momentTags: [PFObject] = []
    
    @IBAction func addButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("moveToSearch", sender: sender)
    }
    override func viewDidLayoutSubviews() {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setStyle()
        trackUser()
        view.addSubview(mapView)
        
        // Set the map view‘s delegate property.
        mapView.delegate = self
        
        
        
        // Initialize and add the point annotation.
        /*let pisa = MGLPointAnnotation()
        pisa.coordinate = CLLocationCoordinate2DMake(57.7039599,11.9657933)
        pisa.title = "Spotify"
        mapView.addAnnotation(pisa)
       */
        view.sendSubviewToBack(mapView)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(pollForTags), userInfo: nil, repeats: true)
    }
    
    func pollForTags() {
        //Find all tags in database
        //Exclude already found tags
        var predicate: NSPredicate? = nil
        if momentTags.count > 0 {
            var objectIds: [String] = []
            for momentTag in momentTags {
                objectIds.append(momentTag.objectId!)
                
                //print("not equal to \(momentTag.objectId!)")
            }
            predicate = NSPredicate(format: "NOT (objectId IN %@)", objectIds)
        }
        
        let query = PFQuery(className: "MomentTag", predicate: predicate)
        
        query.findObjectsInBackgroundWithBlock {
            (newMomentTags: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                print("Error: \(error!) \(error!.userInfo)")
            } else if var newMomentTags = newMomentTags {
                if newMomentTags.count > 0 {
                    print("Found \(newMomentTags.count) new tags.")
                    self.momentTags += newMomentTags
                    
                    for momentTag in newMomentTags {
                        if let position = momentTag["position"] as? PFGeoPoint {
                            let annotation = MGLPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2DMake(position.latitude, position.longitude)
                            annotation.title = momentTag.objectId!
                            
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
        }
    }
    
    
    func getUserLocation() -> CLLocationCoordinate2D {
        let location = MGLUserLocation()
        return location.coordinate
    }
    
    func setStyle() {
        
        mapView.setZoomLevel(16, animated: false)
        
        // Fill in the next line with your style URL from Mapbox Studio.
        let styleURL = NSURL(string: MomentsConfig.mapbox.styleUrl)
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(mapView)
        

        
        
    }
    
    func trackUser() {
        mapView.userTrackingMode = MGLUserTrackingMode.Follow
        
    }

    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        
        var fallbackImage = mapView.dequeueReusableAnnotationImageWithIdentifier("fallback")
        if fallbackImage == nil {
             var image = UIImage(named: "plus")!
             image = resizeImage(image)
             image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            fallbackImage = MGLAnnotationImage(image: image, reuseIdentifier: "fallback")
        }
        
        let objectId = annotation.title!
        
        //Find corresponding moment tag
        if let momentTagIndex = momentTags.indexOf({$0.objectId == objectId}) {
            let momentTag = momentTags[momentTagIndex]
            
            var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(objectId!)
            
            if annotationImage == nil {
                if let thumbnailFile = momentTag["thumbnail"] as? PFFile {
                    if thumbnailFile.dataAvailable {
                        if let data = try? thumbnailFile.getData() {
                            let image = UIImage(data:data, scale: 2.0)
                            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: objectId!)
                            return annotationImage
                        }
                    } else {
                        thumbnailFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            print("DOwnloaded thumbnail, should reset thumbnails")
                            mapView.removeAnnotation(annotation)
                            mapView.addAnnotation(annotation)
                        }
                        return fallbackImage
                    }
                }
            }
        }
        
        return fallbackImage
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return false
    }
    
    
    func resizeImage(image:UIImage) -> UIImage
    {
        var actualHeight:Float = Float(image.size.height)
        var actualWidth:Float = Float(image.size.width)
        
        let maxHeight:Float = 70.0 //your choose height
        let maxWidth:Float = 70.0  //your choose width
        
        var imgRatio:Float = actualWidth/actualHeight
        let maxRatio:Float = maxWidth/maxHeight
        
        if (actualHeight > maxHeight) || (actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect:CGRect = CGRectMake(0.0, 0.0, CGFloat(actualWidth) , CGFloat(actualHeight) )
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        
        let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData:NSData = UIImageJPEGRepresentation(img, 1.0)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToSearch"
        {
            if let destinationVC = segue.destinationViewController as? SearchViewController {
                destinationVC.userCoordinate = mapView.userLocation?.coordinate
                print("userCoordinate: \(mapView.userLocation?.coordinate)")
            }
        }
    }
}




