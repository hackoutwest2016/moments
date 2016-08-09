//
//  LoginViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//


class LoginViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingDelegate {
    var player:SPTAudioStreamingController?
    
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
        print("Fail to login")
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Cancel login")
    }
    
    
    
    
    func loginUsingSession(session:SPTSession){
        // Get the player instance
        self.player = SPTAudioStreamingController.sharedInstance()
        self.player!.delegate = self;
        // Start the player (will start a thread)
        do {
            try self.player?.startWithClientId("e68a7d2684a1480a92c76af243bf0a30")
            print("try player")
        }
        catch _{
            print("catch error in loginUS")
        }
        
        // self.player startWithClientId:@"e68a7d2684a1480a92c76af243bf0a30" error:nil];
        // Login SDK before we can start playback
        self.player?.loginWithAccessToken(session.accessToken)
        
    }
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        
        let option = SPTPlayOptions()
        option.startTime = 50
        
        let trackUri:NSURL! = NSURL.init(string: "spotify:track:5WBxAaS9nNnWTH469p0Ht0")
        // self.player!.playURIs([trackUri], fromIndex: 0,  callback: nil)
        
        
        
        self.player!.playURIs([trackUri], withOptions: option, callback: nil)
        
        
        //        let option = SPTPlayOptions()
        //        option.startTime = 0.4
        //
        //
        //        let firstSong = NSURL.init(string: "spotify:track:5WBxAaS9nNnWTH469p0Ht0")
        //        var trackUris = [NSURL]()
        //        trackUris.append(firstSong!)
        //
        //
        //        self.player!.playURIs(trackUris, withOptions: option) { (err) in
        //            print(err!)
        //        }
        //        
        
    }
    
}
