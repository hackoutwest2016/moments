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



class DiscoverViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill in the next line with your style URL from Mapbox Studio.
        let styleURL = NSURL(string: "mapbox://styles/heddao/cirnd85rm000fgzni87petcp9")
        let mapView = MGLMapView(frame: view.bounds,
                                 styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
       
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude:  7.7039557,
            longitude: 1.9637917),
                                    zoomLevel: 14, animated: false)
        
        mapView.userTrackingMode = MGLUserTrackingMode.Follow
        view.addSubview(mapView)
    }
}