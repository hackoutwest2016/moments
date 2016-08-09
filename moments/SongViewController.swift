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

class SongViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    var momentTag: PFObject? {
        didSet {
            //Fetch video files from parse and save to a file
            if let videos = momentTag!["videos"] as? [PFObject] {
                
                downloadedVideos = 0
                videosToDownload = videos.count
                localVideoUrls = [NSURL]()
                
                for video in videos {
                    video.fetchIfNeededInBackgroundWithBlock {
                        (video: PFObject?, error: NSError?) -> Void in
                        if let video = video {
                            if let userVideoFile = video["videoFile"] as? PFFile {
                                userVideoFile.getDataInBackgroundWithBlock {
                                    (videoData: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let videoData = videoData {
                                            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
                                            let destinationUrl = documentsUrl.URLByAppendingPathComponent(userVideoFile.name)
                                            
                                            if videoData.writeToURL(destinationUrl, atomically: true) {
                                                print("file saved [\(destinationUrl.path!)]")
                                                self.videoDownloaded(destinationUrl, error: nil) //success
                                            } else {
                                                print("error saving file")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //print(videos?["videoFile"])
        }
    }
    
    var spotifyUrl: String? {
        didSet {
            
        }
    }
    
    var currentOffset: Float = 0 //In seconds

    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var mediaView: UIView!
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    var videosToDownload = 2
    var downloadedVideos = 0
    var localVideoUrls = [NSURL]()
    
    var spotifyPlayer: SPTAudioStreamingController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotifyPlayer = SPTAudioStreamingController.sharedInstance()
        spotifyPlayer?.playbackDelegate = self
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)
    }
    
    func updateSongProgress() {
        if let spotifyPlayer = spotifyPlayer {
            if spotifyPlayer.isPlaying {
                let playbackPosition = spotifyPlayer.currentPlaybackPosition
                currentOffset = Float(playbackPosition)
                slider.value = currentOffset/Float(spotifyPlayer.currentTrackDuration)
            }
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
            
            videoPlayer = AVPlayer(playerItem: stitchedVideo.PlayerItem)
            videoPlayer?.actionAtItemEnd = .None
            
            videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
            videoPlayerLayer!.frame = self.mediaView.bounds
            self.view.layer.addSublayer(videoPlayerLayer!)
        }
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        print(sender.value)
        let musicDuration = Float(spotifyPlayer!.currentTrackDuration)
        let musicOffset = musicDuration * sender.value
        setMusicOffset(musicOffset)
    }
    
    func setMusicOffset(musicOffset: Float) {
        currentOffset = musicOffset
        
        let videoDuration = Float(videoPlayer!.currentItem!.duration.seconds)
        var videoOffset = musicOffset
        if(musicOffset > videoDuration) {
            //TODO: Show empty image instead of video
            videoOffset = videoDuration
        }
        videoPlayer?.seekToTime(CMTime(seconds: Double(videoOffset), preferredTimescale: 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        spotifyPlayer?.seekToOffset(Double(musicOffset), callback: { (error: NSError!) in
            if error != nil {
                print("Seek error \(error)")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mediaViewTapped(sender: AnyObject) {
        
        if let videoPlayer = videoPlayer {
            
            print(videoPlayer.currentItem?.loadedTimeRanges)
            print(videoPlayer.rate)
            if videoPlayer.rate > 0 {
                print("pause")
                videoPlayer.pause()
                spotifyPlayer?.setIsPlaying(false, callback: { (error: NSError!) in
                    if error != nil {
                        print("Couldnt pause spotify")
                    }
                })
            } else {
                if videoPlayer.status == .ReadyToPlay {
                    print("play")
                    //videoPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    if let spotifyUrl = spotifyUrl {
                        spotifyPlayer?.playURIs([NSURL(string: spotifyUrl)!], fromIndex: 0, callback: { (error: NSError!) in
                            if error != nil {
                                print("Couldnt play from spotify")
                            } else {
                                self.setMusicOffset(self.currentOffset)
                                videoPlayer.play()
                            }
                        })
                    }
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
