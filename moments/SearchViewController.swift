//
//  SearchViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
// Search a song



import Mapbox


class SearchViewController: UIViewController, MGLMapViewDelegate {
    
    var userCoordinate:CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06)
    //it should be ?
    
    @IBOutlet weak var mapView: MGLMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMiniMap()
        searchSong()
     
    }
    
    func searchSong(){
        
        let search = SPTSearch()
        
        SPTRequest.performSearchWithQuery("ta det lugnt", queryType: SPTSearchQueryType.QueryTypeTrack, session: nil) { (error, data) in
            print(data)
            let items = (data as! SPTListPage).items
            print(items)
            
            //take the first one
            let selectedSong = items.first as! SPTPartialTrack
            print(selectedSong.name)
            print(selectedSong.artists)
            
        }
        
        
        
    }
    func setUpMiniMap(){
        //let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
        let coordinate = userCoordinate!
        mapView.setCenterCoordinate(coordinate, zoomLevel: 16, animated: false)
        
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        // Declare the marker `hello` and set its coordinates, title, and subtitle.
        let pin = MGLPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "pin!"
        pin.subtitle = ""
        
        // Add marker `pin` to the map.
        mapView.addAnnotation(pin)
        
        mapView.showsUserLocation = false
        mapView.userInteractionEnabled = true
        
        print("userCoordinate in SearchVC :\(userCoordinate)")
    }
}