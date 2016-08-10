//
//  SearchViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
// Search a song



import Mapbox


class SearchViewController: UIViewController, MGLMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var selectedSong: Song?
    var filteredSongs = [Song]()
    let searchController = UISearchController(searchResultsController: nil)
    var userCoordinate: CLLocationCoordinate2D?
    //it should be ? or = CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06)
    
    //typealias song = (artist:String,song:String)
    var songs:[Song] = []
    let textCellIdentifier = "TrackCell"
    
    @IBOutlet weak var songListView: UITableView!
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMiniMap()
        setUpSongListView()
        setUpSearchBar()
        
    }
    
    
    //MARK:Basic Set Ups
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
        mapView.userInteractionEnabled = false

    
        let styleURL = NSURL(string: MomentsConfig.mapbox.styleUrl)
        mapView.styleURL = styleURL

    }
    
    func setUpSearchBar(){
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        songListView.tableHeaderView = searchController.searchBar
    }
    
    func setUpSongListView(){
        songListView.delegate = self
        songListView.dataSource = self
    }
    
    
    
    //MARK:Search Bar
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSongs = songs.filter { song in
            return song.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        songListView.reloadData()
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
      
        let keyword = searchController.searchBar.text
        if let k = keyword {
            if(k != ""){
                searchSong(k)
            }
        }
    }
    
    func searchSong(keyword:String){
        
        SPTRequest.performSearchWithQuery(keyword, queryType: SPTSearchQueryType.QueryTypeTrack, session: nil) { (error, data) in
            //remove all songs in array
            
            
            //get all results on the first page to the table view
            if let items = (data as! SPTListPage).items{
                //update the table
                var array = [Song]()
                for n in 0..<items.count {
                    if let currentItem = items[n] as? SPTPartialTrack{
                        //just gonna pretend there is only one artist
                        let artist = currentItem.artists.first as! SPTPartialArtist
                        let songName = currentItem.name
                        let currentSong:Song = Song(artist:artist.name,name:songName, link: currentItem.identifier)
                        array.append(currentSong)
                        
                    }
                    
                    self.songs.removeAll()
                    self.songs = array
                    self.songListView.reloadData()
                }
            }
        }
        
    }
    
    
    //MARK:Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        print("row:\(row)")
        print("songs.count:\(songs.count)")
        
        cell.textLabel?.text = songs[row].name
        cell.detailTextLabel?.text = songs[row].artist
        
        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        selectedSong = songs[row]
        performSegueWithIdentifier("moveToRecord", sender: nil)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToRecord"
        {
            if let destinationVC = segue.destinationViewController as? SongViewController {
                destinationVC.spotifySong = selectedSong!
                var newTag = PFObject(className: "MomentTag")
                
                if let location = self.userCoordinate {
                    var position = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                    newTag["position"] = position
                }
                destinationVC.momentTag = newTag
            }
        }
    }
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        //TODO: Return
        //performSegueWithIdentifier("unwindSegue2", sender: self)
    }
}


struct Song {
    let artist : String
    let name : String
    let link : String
}


