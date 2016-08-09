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
    
    var mapView = MGLMapView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        trackUser()
        
        
        

        view.addSubview(mapView)
        
      
        
        // Set the map view‘s delegate property.
        mapView.delegate = self
        
        // Initialize and add the point annotation.
        let pisa = MGLPointAnnotation()
        pisa.coordinate = CLLocationCoordinate2DMake(57.7039599,11.9657933)
        pisa.title = "Spotify"
        mapView.addAnnotation(pisa)
    }
    
    
    func getUserLocation() -> CLLocationCoordinate2D {
        let location = MGLUserLocation()
        return location.coordinate
    }
    func setStyle() {
        
        mapView.setZoomLevel(16, animated: false)
        
        // Fill in the next line with your style URL from Mapbox Studio.
        let styleURL = NSURL(string: "mapbox://styles/heddao/cirnd85rm000fgzni87petcp9")
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(mapView)
        

        
        
    }
    
    func trackUser() {
        mapView.userTrackingMode = MGLUserTrackingMode.Follow
        
    }

    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("pisa")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "hat")!
            image = resizeImage(image)
            
           
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pisa")
            
         
        }
        
        return annotationImage
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
}




