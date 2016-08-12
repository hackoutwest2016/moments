//
//  LoginViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//


class LoginViewController: UIViewController, SPTAuthViewDelegate {
    
    @IBOutlet weak var animationImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var animationImages = [UIImage]()
        
        for i in 0...84 {
            let animationFrame = UIImage(named: "moments\(i)")
            animationImages.append(animationFrame!)
        }
        
        animationImageView.animationImages = animationImages
        animationImageView.animationDuration = 2
        animationImageView.animationRepeatCount = 1
        
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        animationImageView.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        /*
        var tag = PFObject(className: "MomentTag")
        var video1 = PFObject(className: "MomentVideo")
        var video2 = PFObject(className: "MomentVideo")
        tag["position"] = PFGeoPoint(latitude: 57.7039599, longitude: 11.9657933)
        tag["videos"] = [video1,video2]
        tag.saveInBackground()
        */
        
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
        //
        //        }
        
           spotifyLoginPopUp()
        
    }
    
    func spotifyLoginPopUp(){
        let auth = SPTAuth.defaultInstance()
        auth.clientID        = MomentsConfig.spotify.clientId
        auth.redirectURL     = NSURL.init(string:MomentsConfig.spotify.redirectUrl)
        auth.requestedScopes = [SPTAuthStreamingScope]
        
        let authvc = SPTAuthViewController.authenticationViewController()
        // authvc.clearCookies(nil)
        authvc.modalPresentationStyle   = UIModalPresentationStyle.OverCurrentContext
        authvc.modalTransitionStyle     = UIModalTransitionStyle.CrossDissolve
        authvc.delegate                 = self
        
        self.modalPresentationStyle     = UIModalPresentationStyle.CurrentContext
        self.definesPresentationContext = true
        self.presentViewController(authvc, animated: true, completion: nil)
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Login")
        
        self.loginUsingSession(session)
        
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("Failed to login")
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Cancelled Spotify login")
    }
    

    func loginUsingSession(session:SPTSession){
        // Get the player instance
        if let spotifyPlayer = SPTAudioStreamingController.sharedInstance() {
            
            // Start the player (will start a thread)
            if (try? spotifyPlayer.startWithClientId(MomentsConfig.spotify.clientId)) == nil {
                print("Login error")
            }
            
            // Login SDK before we can start playback
            spotifyPlayer.loginWithAccessToken(session.accessToken)
        } else {
            print("Couldnt find spotify instance")
        }
        
        performSegueWithIdentifier("moveToDiscover", sender: nil)
        //performSegueWithIdentifier("debug_moveToSong", sender: nil)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToDiscover"
        {
            if let destinationVC = segue.destinationViewController as? LoginViewController {
//                destinationVC.numberToDisplay = counter
            }
        }
        if segue.identifier == "debug_moveToSong"
        {
            if let destinationVC = segue.destinationViewController as? SongViewController {
                let query = PFQuery(className:"MomentTag")
                
                
                query.getObjectInBackgroundWithId("lKABghHrhM").continueWithBlock({
                    (task: BFTask!) -> AnyObject! in
                    if task.error != nil {
                        // There was an error.
                        print("ERROR in retreiving debug moment tag")
                        return task
                    }
                    
                    destinationVC.momentTag = task.result as? PFObject
                    destinationVC.spotifySong = Song(artist: "Woho", name: "Wanna get ready", link: "spotify:track:6sqo5lYZ3yJRv0auIWBNrm")
                    return task
                })
            }
        }
    }
    

    
}
