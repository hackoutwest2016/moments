//
//  SongViewController.swift
//  moments
//
//  Created by Pak on 09/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//
// Play a selected song/video

import UIKit
import AVFoundation

class SongViewController: UIViewController {

    @IBOutlet weak var mediaView: UIView!
    var moviePlayer: AVPlayer?
    
    var videosToDownload = 2
    var downloadedVideos = 0
    var remoteVideoUrls = [NSURL(string: "http://localhost:8080/video1.mp4")!,NSURL(string: "http://localhost:8080/video2.mp4")!]
    var localVideoUrls = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        videosToDownload = 2
        downloadedVideos = 0
        localVideoUrls = [NSURL]()
        
        //Download videos
        for remoteVideoUrl in remoteVideoUrls {
            HttpDownloader.loadFileAsync(remoteVideoUrl, completion:videoDownloaded)
        }
    }
    
    func videoDownloaded(url: NSURL, error: NSError!) {
        //TODO: error handling (not downloaded)
        print("Video downloaded to \(url)")
        localVideoUrls.append(url)
        downloadedVideos += 1
        
        if downloadedVideos == videosToDownload {
            print(localVideoUrls)
            print("Download done")
            
            let stitchedVideo = StitchedVideo(videoUrls: localVideoUrls)
            
            moviePlayer = AVPlayer(playerItem: stitchedVideo.PlayerItem)
            
            let playerLayer = AVPlayerLayer(player: moviePlayer)
            playerLayer.frame = self.mediaView.bounds
            self.view.layer.addSublayer(playerLayer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mediaViewTapped(sender: AnyObject) {
        
        if let moviePlayer = moviePlayer {
            
            print(moviePlayer.currentItem?.loadedTimeRanges)
            print(moviePlayer.rate)
            if moviePlayer.rate > 0 {
                print("pause")
                moviePlayer.pause()
            } else {
                if moviePlayer.status == .ReadyToPlay {
                    print("play")
                    moviePlayer.play()
                    moviePlayer.rate = 1
                } else {
                    print("NOT READY!")
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
