//
//  LoginViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//


class LoginViewController: UIViewController, SPTAuthViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        let auth = SPTAuth.defaultInstance()
        auth.clientID        = "f51e1e2a1bad4bbfaa3350f7472696d7"
        auth.redirectURL     = NSURL.init(string:"moments-login://callback")
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
            if (try? spotifyPlayer.startWithClientId("e68a7d2684a1480a92c76af243bf0a30")) == nil {
                print("Login error")
            }
            
            // Login SDK before we can start playback
            spotifyPlayer.loginWithAccessToken(session.accessToken)
        } else {
            print("Couldnt find spotify instance")
        }
        
        performSegueWithIdentifier("moveToDiscover", sender: nil)

        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToDiscover"
        {
            if let destinationVC = segue.destinationViewController as? LoginViewController {
//                destinationVC.numberToDisplay = counter
            }
        }
    }
    

    
}
