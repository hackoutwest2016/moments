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

    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var mediaView: UIView!
    var moviePlayer: AVPlayer?
    var moviePlayerLayer: AVPlayerLayer?
    
    var videosToDownload = 2
    var downloadedVideos = 0
    //var remoteVideoUrls = [NSURL(string: "http://localhost:8080/video1.mp4")!,NSURL(string: "http://localhost:8080/video1.mp4")!]
    var localVideoUrls = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Download video files with Parse
        
        let predicate = NSPredicate(format: "videoName BEGINSWITH 'Video'")
        var query = PFQuery(className:"UserVideo", predicate: predicate)
        //query.whereKey("videoFile", equalTo:"video")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        print(object.objectId)
                        
                        if let userVideoFile = object["videoFile"] as? PFFile {
                            userVideoFile.getDataInBackgroundWithBlock {
                                (videoData: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    if let videoData = videoData {
                                        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
                                        let destinationUrl = documentsUrl.URLByAppendingPathComponent(userVideoFile.name)
                                        if videoData.writeToURL(destinationUrl, atomically: true) {
                                            print("file saved [\(destinationUrl.path!)]")
                                            self.videoDownloaded(destinationUrl, error: nil)
                                            //completion(url: destinationUrl, error:nil)
                                        } else {
                                            print("error saving file")
                                            //let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                            //completion(url: destinationUrl, error:error)
                                        }
                                    }
                                }
                            }
                        } else {
                            print("It isn't a file")
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        // Do any additional setup after loading the view.
        videosToDownload = 2
        downloadedVideos = 0
        localVideoUrls = [NSURL]()
        
        //Download videos
        /*for remoteVideoUrl in remoteVideoUrls {
            HttpDownloader.loadFileAsync(remoteVideoUrl, completion:videoDownloaded)
        }*/
    }
    
    func videoDownloaded(url: NSURL, error: NSError!) {
        //TODO: error handling (not downloaded)
        print("Video downloaded to \(url)")
        localVideoUrls.append(url)
        downloadedVideos += 1
        
        //Upload
        /*let videoData = NSData(contentsOfURL: url)
        let videoFile = PFFile(name:"video2.mp4", data:videoData!)
        
        var userVideo = PFObject(className:"UserVideo")
        userVideo["videoName"] = "Video 2"
        userVideo["videoFile"] = videoFile
        userVideo.saveInBackground()
        */
        if downloadedVideos == videosToDownload {
            print(localVideoUrls)
            print("Download done")
            
            let stitchedVideo = StitchedVideo(videoUrls: localVideoUrls)
            
            moviePlayer = AVPlayer(playerItem: stitchedVideo.PlayerItem)
            
            moviePlayerLayer = AVPlayerLayer(player: moviePlayer)
            moviePlayerLayer!.frame = self.mediaView.bounds
            self.view.layer.addSublayer(moviePlayerLayer!)
        }
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        print(sender.value)
        let duration = Float(moviePlayer!.currentItem!.duration.seconds)
        let seconds = Double(duration * sender.value)
        
        moviePlayer?.seekToTime(CMTime(seconds: seconds, preferredTimescale: 1))
        moviePlayer?.play()
        /*spotifyPlayer?.seekToOffset(seconds, callback: { (error: NSError!) in
            if error != nil {
                print("Seek error \(error)")
            }
        })*/
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
                    moviePlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    moviePlayer.play()
                    
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
