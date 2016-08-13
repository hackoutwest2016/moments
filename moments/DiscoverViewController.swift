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



class DiscoverViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    
    var selectedParseId = ""
    
    var mapView = MGLMapView()
    
    var momentTags: [PFObject] = []
    
    let locationManager = CLLocationManager()
    
    @IBAction func addButtonTapped(sender: UIButton) {
        
        //fakeAnnotation()
        performSegueWithIdentifier("moveToSearch", sender: sender)
    }
    
    func fakeAnnotation() {
        let newTag = PFObject(className: "MomentTag")
        let location =  mapView.userLocation!.coordinate
        let parseLocation = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        newTag["position"] = parseLocation
        let imageData = UIImagePNGRepresentation(UIImage(named: "hat")!)
        let thumbnailFile = PFFile(name: "thumb.png", data: imageData!)
        newTag["thumbnail"] = thumbnailFile
        newTag["debug"] = "y"
        newTag.ACL?.publicWriteAccess = true
        newTag.ACL?.publicReadAccess = true
        
        newTag.saveInBackground()
        
        
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
        
        
        view.sendSubviewToBack(mapView)
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(pollForTags), userInfo: nil, repeats: true)
    }
    
    
//    func createMarker(chosenImg:UIImage) -> UIImage{
//        // the chosen image
//        
//        var roundedImg = resizeImage(chosenImg)
//        roundedImg = maskRoundedImage(roundedImg, radius: 40)
//        
//        let drop = UIImage(named: "drop")!
//        let combined = combineImages(drop, topImage: roundedImg)
//        
//        return combined
//    }
    
    
    func combineImages(bottomImage:UIImage, topImage:UIImage) -> UIImage {
        
        //let newSize = CGSizeMake(100, 100) // set this to what you need
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, false, 2.0)
        
        bottomImage.drawInRect(CGRect(origin: CGPointZero, size: bottomImage.size))
        topImage.drawInRect(CGRect(origin: CGPointMake(10, 10), size: topImage.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
                        
                        self.prepareAnnotation(momentTag)
                        
                    }
                }
            }
        }
    }
    
    var annotationImages = [String: CustomAnnotationView]() //objectId -> CustomAnnotationView
    
    func prepareAnnotation(momentTag: PFObject) {
        if let thumbnailFile = momentTag["thumbnail"] as? PFFile {
            
            thumbnailFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error != nil {
                    print("Error in downloading thumbnail")
                } else {
                    inBackground(withData: nil, run: { data in
                        let reuseIdentifier = momentTag.objectId
                        
                        var thumbnail = UIImage(data:imageData!, scale: 2.0)
                        // make it rounded
                        thumbnail = ImageCropper.cropToCircle(thumbnail!, radius: Float((thumbnail?.size.height)!/2))
                        
                        //size of images
                        let imageSize:CGFloat = 60
                        
                        let thumbnailView  = UIImageView(image: thumbnail)
                        thumbnailView.frame = CGRectMake(5, 5, imageSize, imageSize)
                        
                        //style
                        thumbnailView.layer.cornerRadius = thumbnailView.frame.width / 2
                        let tagView = UIImageView(image: UIImage(named: "drop"))
                        tagView.addSubview(thumbnailView)
                        
                        let annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
                        
                        annotationView.addSubview(tagView)
                        tagView.frame = CGRect(origin: CGPointZero , size: tagView.frame.size)
                        annotationView.frame = tagView.frame
                        
                        annotationView.transform = CGAffineTransformMakeTranslation(0 - tagView.frame.width/2, 0 - tagView.frame.height)
                        tagView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                        
                        self.annotationImages[momentTag.objectId!] = annotationView
                        
                        return tagView
                    }, then: { result in
                        if let position = momentTag["position"] as? PFGeoPoint {
                            let annotation = MGLPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2DMake(position.latitude, position.longitude)
                            annotation.title = momentTag.objectId!
                            self.mapView.addAnnotation(annotation)
                            
                            if let tagView = result as? UIView {
                                UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping: 0.1, initialSpringVelocity: 4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    tagView.transform = CGAffineTransformMakeScale(1, 1)
                                    }, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    func getUserLocation() -> CLLocationCoordinate2D {
        let location = MGLUserLocation()
        return location.coordinate
    }
    
    func setStyle() {
        
        // 20 is max
        mapView.setZoomLevel(16, animated: false)
        let styleURL = NSURL(string: MomentsConfig.mapbox.styleUrl)
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(mapView)
        
        
    }
    
    func trackUser() {
        mapView.userTrackingMode = MGLUserTrackingMode.Follow
        
    }
    
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        // the annotation.title was previously set to be the objectId of moment tag object
        let objectId = annotation.title!
        
        //Find corresponding moment tag
        if let momentTagIndex = momentTags.indexOf({$0.objectId == objectId}) {
            let momentTag = momentTags[momentTagIndex]
            
            if annotationView == nil {
                annotationView = self.annotationImages[momentTag.objectId!]
            }
        }
        
        return annotationView
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return false
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        print("seelected")
        selectedParseId = annotation.title!!
        performSegueWithIdentifier("moveToViewSong", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToSearch"
        {
            if let destinationVC = segue.destinationViewController as? SearchViewController {
                destinationVC.userCoordinate = mapView.userLocation?.coordinate
                print("userCoordinate: \(mapView.userLocation?.coordinate)")
                
            }
        }
        
        if segue.identifier == "moveToViewSong"
        {
            if let destinationVC = segue.destinationViewController as? SongViewController {
                if selectedParseId != "" {
                    for momentTag in momentTags {
                        
                        if momentTag.objectId == selectedParseId {
                            
                            destinationVC.momentTag = momentTag

                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        //TODO: Return
        /*if let previousVS = sender.sourceViewController as? SongViewController {
         if let momentTagIndex = momentTags.indexOf({$0.objectId == previousVS.momentTag?.objectId}) {
         let momentTag = momentTags[momentTagIndex]
         
         if let annotationIndex = mapView.annotations!.indexOf({$0.title! == momentTag.objectId}) {
         let annotation = mapView.annotations![annotationIndex]
         
         mapView.removeAnnotation(annotation)
         mapView.addAnnotation(annotation)
         //TODO POP animation
         }
         }
         }*/
        //performSegueWithIdentifier("unwindSegue1", sender: self)
    }
}


class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
        //        layer.cornerRadius = frame.width / 2
        //        layer.borderWidth = 3
        //        layer.borderColor = Palette.purple.CGColor
    }
    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
////        // Animate the border width in/out, creating an iris effect.
////        let animation = CABasicAnimation(keyPath: "borderWidth")
////        animation.duration = 0.1
////        layer.borderWidth = selected ? frame.width / 4 : 2
////        layer.addAnimation(animation, forKey: "borderWidth")
//    }
}


