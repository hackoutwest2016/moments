//
//  SearchViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
// Search a song



import Mapbox


class SearchViewController: UIViewController, MGLMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var userCoordinate:CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06)
    //it should be ?
    
    typealias song = (artist:String,song:String)
    var dataSource:[song] = []
    let textCellIdentifier = "TrackCell"
    
    @IBOutlet weak var songListView: UITableView!
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMiniMap()
        
        setUpSongListView()
        searchSong()
        
        
    }
    
    func setUpSongListView(){
        songListView.delegate = self
        songListView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = dataSource[row].song
        cell.detailTextLabel?.text = dataSource[row].artist
        
        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        //print(swiftBlogs[row])
    }
    
    
    func searchSong(){
        
        let search = SPTSearch()
        
        SPTRequest.performSearchWithQuery("ta det lugnt", queryType: SPTSearchQueryType.QueryTypeTrack, session: nil) { (error, data) in
            //print(data)
            let items = (data as! SPTListPage).items
            //print(items)
            
            //take the first one
            let selectedSong = items.first as! SPTPartialTrack
//            print(selectedSong.name)
//            print(selectedSong.artists)
            
            //update the table
            for n in 0..<items.count {
                let currentItem = items[n] as! SPTPartialTrack
                print(currentItem.artists)
                
                //just gonna pretend there is only one artist
                let artist = currentItem.artists.first as! SPTPartialArtist
                let songName = currentItem.name
                let currentSong:song = (artist.name , songName)
                self.dataSource.append(currentSong)
            }
           
            
          
            
            self.songListView.reloadData()
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