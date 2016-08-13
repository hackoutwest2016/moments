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

class SongViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var timelineViewParent: UIView!
    @IBOutlet weak var timelineView: UIView!
    
    @IBOutlet weak var captureLabel: UILabel!
    
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var holdLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var overlay: UIView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var musicSlider: UISlider!
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    private var spotifySong: Song? {
        didSet {
            artistLabel?.text = spotifySong?.artist
            songLabel?.text = spotifySong?.name
        }
    }
    
    var momentTag: PFObject? {
        didSet {
            
            //spotify URI
            var spotifyUrl = momentTag?["spotifyUrl"] as? String
            if (spotifyUrl == nil){
                spotifyUrl = "0EFEkt29P7Icr7dO4vN6yk"
            }
            
            self.spotifySong = Song(artist: "Test", name: "Test", link: spotifyUrl!)
            
            SPTTrack.trackWithURI(NSURL(string: "spotify:track:"+spotifyUrl!), session: nil, callback: { (error, data) in
                if let track = data as? SPTTrack{
                    print(track)
                    print(track.artists.first)
                    print(track.name)
                    
                    let artist =  "\((track.artists.first as! SPTPartialArtist).name)"
                    let name = track.name
                    self.spotifySong = Song(artist: artist, name: name, link: spotifyUrl!)
                    
                    print("spotifySong: \(self.spotifySong)")
                    
                    self.spotifyReady = true
                    self.playIfReady()
                }
            })
            
            
            //Fetch video files from parse and save to a file
            let query = PFQuery(className: "MomentVideo")
            query.whereKey("parent", equalTo: momentTag!)
            query.orderByAscending("createdAt")
            
            query.findObjectsInBackgroundWithBlock { (videos: [PFObject]?, error: NSError?) in
                if let videos = videos {
                    
                    self.downloadedVideos = 0
                    self.videosToDownload = videos.count
                    self.localVideoUrls = [NSURL](count: self.videosToDownload, repeatedValue: NSURL())
                    
                    if self.videosToDownload == 0 {
                        print("play without videos")
                        self.videoReady = true
                        self.videoAvailable = false
                        self.playIfReady()
                    } else {
                        
                        for (index, video) in videos.enumerate() {
                            if let userVideoFile = video["videoFile"] as? PFFile {
                                userVideoFile.getDataInBackgroundWithBlock {
                                    (videoData: NSData?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let videoData = videoData {
                                            inBackground(withData:nil, run: { data in
                                                let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
                                                let destinationUrl = documentsUrl.URLByAppendingPathComponent(userVideoFile.name)
                                                
                                                if videoData.writeToURL(destinationUrl, atomically: true) {
                                                    //print("file saved [\(destinationUrl.path!)]")
                                                    self.videoDownloaded(index,url: destinationUrl, error: nil) //success
                                                } else {
                                                    print("error saving file")
                                                }
                                            }, then: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.downloadedVideos = 0
                    self.videosToDownload = 0
                    self.localVideoUrls = [NSURL]()
                    self.videoReady = true
                    self.videoAvailable = false
                    self.playIfReady()
                }
            }
        }
    }
    
    private var currentOffset: Float = 0 {
        didSet {
            if(currentOffset > videoDuration-0.1) {
                if !recordingDone {
                    cameraLayer?.hidden = false
                    videoPlayerLayer?.hidden = true
                } else {
                    cameraLayer?.hidden = true
                    videoPlayerLayer?.hidden = false
                }
                if startedRecording {
                    captureLabel.hidden = true
                    holdLabel.hidden = true
                } else {
                    captureLabel.hidden = false
                    holdLabel.hidden = false
                }
            } else {
                cameraLayer?.hidden = true
                captureLabel.hidden = true
                holdLabel.hidden = true
                videoPlayerLayer?.hidden = false
            }
            
            /*
             for colorDuration in colorDurations {
             if currentOffset > colorDuration.0-0.15 {
             var color = colorDuration.1.colorWithAlphaComponent(0.3)
             overlay?.backgroundColor = color
             }
             }
             */
        }
    }//In seconds
    
    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?
    private var videoDuration: Float = 0
    
    private var videosToDownload = 2
    private var downloadedVideos = 0
    private var localVideoUrls = [NSURL]()
    
    private var spotifyPlayer: SPTAudioStreamingController?
    
    private var boxesXPos: CGFloat = 0.0
    
    
    private let sliderThumbImg = UIImage(named:"slider-thumb")
    private let sliderThumbInvisibleImg = UIImage(named:"slider-thumb-invisible")
    
    private var startedRecording = false
    private var recordingDone = false
    private var videoReady = false
    private var videoAvailable = false
    private var spotifyReady = false
    private var cameraReady = false
    
    //Sorted list with offset in seconds and overlay color
    private var colorDurations: [(Float, UIColor)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotifyPlayer = SPTAudioStreamingController.sharedInstance()
        spotifyPlayer?.playbackDelegate = self
        
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(updateSongProgress), userInfo: nil, repeats: true)
        
        
        //slider.setThumbImage(UIImage(named:"slider-thumb"),forState: .Normal)
        slider.setThumbImage(sliderThumbInvisibleImg,forState: .Normal)
        musicSlider.setThumbImage(UIImage(named:"slider-thumb-music"),forState: .Normal)
        
        saveButton.hidden = true
        redoButton.hidden = true
        cameraLayer?.hidden = true
        captureLabel.hidden = true
        holdLabel.hidden = true
        videoPlayerLayer?.hidden = true
        colorDurations = [(0,MomentsConfig.colors.randomItem())]
        loadingView.hidden = false
        
        //TODO: Spinning wheel
        self.initCamera(.Back)
    }
    
    override func viewDidDisappear(animated: Bool) {
        //Reset everything
        spotifyPlayer?.setIsPlaying(false, callback: nil)
        videoPlayer?.rate = 0
        for subview in self.timelineView.subviews {
            subview.removeFromSuperview()
        }
        saveButton.hidden = true
        redoButton.hidden = true
        cameraLayer?.hidden = true
        captureLabel.hidden = true
        holdLabel.hidden = true
        videoPlayerLayer?.hidden = true
        startedRecording = false
        recordingDone = false
        buttonImage.hidden = false
        self.videoDuration = 0
        self.videoPlayer = nil
        self.videoPlayerLayer?.removeFromSuperlayer()
        self.videoPlayerLayer = nil
        self.boxesXPos = 0
        colorDurations = [(0,MomentsConfig.colors.randomItem())]
        videoReady = false
        videoAvailable = false
        spotifyReady = false
        loadingView.hidden = false
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        artistLabel?.text = spotifySong?.artist
        songLabel?.text = spotifySong?.name
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func updateSongProgress() {
        if let spotifyPlayer = spotifyPlayer {
            if spotifyPlayer.isPlaying {
                let playbackPosition = spotifyPlayer.currentPlaybackPosition
                currentOffset = Float(playbackPosition)
                if recordingDone && currentOffset > videoDuration {
                    slider.value = videoDuration/Float(spotifyPlayer.currentTrackDuration)
                    slider.setThumbImage(sliderThumbInvisibleImg,forState: .Normal)
                } else {
                    slider.value = currentOffset/Float(spotifyPlayer.currentTrackDuration)
                    slider.setThumbImage(sliderThumbImg,forState: .Normal)
                }
                musicSlider.value = currentOffset/Float(spotifyPlayer.currentTrackDuration)
            }
        }
    }
    
    func videoDownloaded(index: Int, url: NSURL, error: NSError!) {
        //TODO: error handling (not downloaded)
        //print("Video downloaded to \(url) with index \(index)")
        localVideoUrls[index] = url
        downloadedVideos += 1
        
        if downloadedVideos == videosToDownload {
            //print(localVideoUrls)
            //print("Download done")
            
            //TODO: Add timeline boxes
            //timelineView
            //timelineView.subviews
            inBackground(withData: nil, run: { data in
                let stitchedVideo = StitchedVideo(videoUrls: self.localVideoUrls)
                //let test = AVPlayerItem(URL: localVideoUrls[0])
                
                self.videoPlayer = AVPlayer(playerItem: stitchedVideo.PlayerItem)
                self.videoPlayer?.actionAtItemEnd = .None
                self.videoDuration = Float(self.videoPlayer!.currentItem!.duration.seconds)
                return nil
            }, then: { result in
                self.mediaView.layoutIfNeeded()
                self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
                self.videoPlayerLayer!.frame = CGRect(x:-120,y:0,width: self.mediaView.bounds.width+120,height: self.mediaView.bounds.height)
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResize
                //videoPlayerLayer!.needsDisplayOnBoundsChange = true
                
                self.mediaView.layer.insertSublayer(self.videoPlayerLayer!, atIndex: 0)
                
                self.videoReady = true
                self.videoAvailable = true
                
                self.playIfReady()
            })
        }
    }
    
    func reloadVideoPlayer() {
        let stitchedVideo = StitchedVideo(videoUrls: localVideoUrls)
        //let shouldPlay = videoPlayer?.rate > 0
        videoPlayer = AVPlayer(playerItem: stitchedVideo.PlayerItem)
        videoPlayer?.actionAtItemEnd = .None
        videoDuration = Float(videoPlayer!.currentItem!.duration.seconds)
        videoPlayerLayer?.removeFromSuperlayer()
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer!.frame = CGRect(x:-120,y:0,width: mediaView.bounds.width+120,height: mediaView.bounds.height)
        videoPlayerLayer!.videoGravity = AVLayerVideoGravityResize
        //videoPlayerLayer!.needsDisplayOnBoundsChange = true
        
        self.mediaView.layer.insertSublayer(videoPlayerLayer!, atIndex: 0)
        
        videoPlayer?.play()
        
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        //print(sender.value)
        let musicDuration = Float(spotifyPlayer!.currentTrackDuration)
        let musicOffset = musicDuration * sender.value
        setMusicOffset(musicOffset)
        slider.value = sender.value
        musicSlider.value = sender.value
    }
    
    func setMusicOffset(musicOffset: Float) {
        currentOffset = musicOffset
        
        var videoOffset = musicOffset
        if(musicOffset >= videoDuration) {
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
        
        //playPause()
    }
    
    
    func playIfReady() {
        print("playIfReady, cameraReady: \(cameraReady), spotifyReady: \(spotifyReady), videoReady: \(videoReady), videoAvailable \(videoAvailable)")
        if cameraReady && spotifyReady && videoReady && videoAvailable {
            if let videoPlayer = videoPlayer {
                if videoPlayer.status == .ReadyToPlay {
                    print("play")
                    //videoPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    if let spotifyUrl = spotifySong?.link {
                        spotifyPlayer?.playURIs([NSURL(string: "spotify:track:"+spotifyUrl)!], fromIndex: 0, callback: { (error: NSError!) in
                            if error != nil {
                                print("Couldnt play from spotify")
                            } else {
                                
                                self.setMusicOffset(self.currentOffset)
                                videoPlayer.play()
                                
                                var totalDuration: Float64 = 0
                                var colorI = 0
                                
                                for videoUrl in self.localVideoUrls {
                                    let asset = AVURLAsset(URL: videoUrl)
                                    let videoDuration = CMTimeGetSeconds(asset.duration)
                                    
                                    let musicDuration = self.spotifyPlayer!.currentTrackDuration
                                    let fragment = CGFloat(videoDuration/musicDuration)
                                    
                                    let color = MomentsConfig.colors[colorI++ % MomentsConfig.colors.count]
                                    
                                    self.colorDurations.append((Float(totalDuration),color))
                                    
                                    let newBox = UIView()
                                    newBox.frame = CGRect(x: self.boxesXPos, y: 0, width: self.timelineView.frame.width * fragment, height: self.timelineView.frame.height)
                                    newBox.backgroundColor = color
                                    self.timelineView.addSubview(newBox)
                                    self.boxesXPos += self.timelineView.frame.width * fragment
                                    
                                    totalDuration += videoDuration
                                }
                                
                                
                                self.loadingView.hidden = true
                            }
                        })
                    }
                } else {
                    print("NOT READY!")
                }
            }
        } else if cameraReady && videoReady && spotifyReady { //No videos just music
            print("play only music")
            if let spotifyUrl = spotifySong?.link {
                spotifyPlayer?.playURIs([NSURL(string: "spotify:track:"+spotifyUrl)!], fromIndex: 0, callback: { (error: NSError!) in
                    if error != nil {
                        print("Couldnt play from spotify")
                    } else {
                        
                        self.setMusicOffset(self.currentOffset)
                        self.loadingView.hidden = true
                    }
                })
            }
            
        }
    }
    
    // MARK: - Camera
    private var cameraLayer : AVCaptureVideoPreviewLayer?
    private var videoOutput : AVCaptureMovieFileOutput?
    private var session : AVCaptureSession?
    private var tm : NSTimer?
    private var recordingDuration : Double = 0
    private var recordingBox : UIView?
    private var recordedVideoUrl: NSURL?
    func initCamera(position: AVCaptureDevicePosition)
    {
        inBackground(withData: nil, run: { data in
            if self.cameraLayer == nil {
                var myDevice: AVCaptureDevice?
                let devices = AVCaptureDevice.devices()
                let audioDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
                
                // Back camera
                var videoInput: AVCaptureDeviceInput? = nil
                for device in devices
                {
                    if(device.position == position)
                    {
                        myDevice = device as? AVCaptureDevice
                        do {
                            videoInput = try AVCaptureDeviceInput(device: myDevice)
                        }
                        catch let error as NSError
                        {
                            print(error)
                            return nil
                        }
                    }
                }
                
                // Audio
                var audioInput: AVCaptureDeviceInput? = nil
                if audioDevices.count > 0 {
                    do {
                        audioInput = try AVCaptureDeviceInput(device: audioDevices[0] as! AVCaptureDevice)
                    }
                    catch let error as NSError
                    {
                        print(error)
                        return nil
                    }
                }
                
                // Create session
                self.videoOutput = AVCaptureMovieFileOutput()
                //imgOutput = AVCaptureStillImageOutput()
                self.session = AVCaptureSession()
                self.session?.beginConfiguration()
                self.session?.sessionPreset = AVCaptureSessionPresetMedium
                
                if videoInput != nil {
                    self.session?.addInput(videoInput)
                }
                if audioInput != nil {
                    self.session?.addInput(audioInput)
                }
                //session?.addOutput(imgOutput)
                self.session?.addOutput(self.videoOutput)
                
                let connection = self.videoOutput?.connectionWithMediaType(AVMediaTypeVideo)
                connection?.videoOrientation = .Portrait
                
                self.session?.commitConfiguration()
                
                
                
                // Start session
                self.session?.startRunning()
                
            }
            return nil
        }, then: { result in
            // Video Screen
            self.mediaView.layoutIfNeeded()
            self.cameraLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.cameraLayer?.frame = self.mediaView.bounds
            self.cameraLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.mediaView.layer.insertSublayer(self.cameraLayer!, atIndex: 0)
            self.cameraReady = true
            self.playIfReady()
        })
        
    }
    
    @IBAction func takeVideo(sender: UILongPressGestureRecognizer) {
        switch sender.state
        {
        case UIGestureRecognizerState.Began:
            print("long tap begin")
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            guard let docDirectory = paths[0] as String? else
            {
                return
            }
            let path = "\(docDirectory)/temp.mp4"
            let url = NSURL(fileURLWithPath: path)
            videoOutput?.startRecordingToOutputFileURL(url, recordingDelegate: self)
            setMusicOffset(videoDuration)
            cameraLayer?.borderColor = MomentsConfig.yellow.CGColor
            cameraLayer?.borderWidth = 10
            buttonImage.hidden = true
            
            startedRecording = true
            
            // Timer
            tm = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("recordVideo:"), userInfo: nil, repeats: true)
            
            //Yellow recording bar
            
            recordingBox = UIView()
            recordingBox!.frame = CGRect(x: boxesXPos, y: -30, width: 1, height: self.timelineView.frame.height)
            recordingBox!.backgroundColor = MomentsConfig.colors.randomItem()
            self.timelineView.addSubview(recordingBox!)
            
        case UIGestureRecognizerState.Ended:
            print("long tap end")
            tm?.invalidate()
            videoOutput?.stopRecording()
            cameraLayer?.borderWidth = 0
            
        default:
            break
        }
    }
    
    internal func recordVideo(tm: NSTimer)
    {
        let interval = 0.01
        let musicDuration = self.spotifyPlayer!.currentTrackDuration
        recordingDuration += interval
        let fragment = CGFloat(recordingDuration/musicDuration)
        
        recordingBox?.frame = CGRect(x: boxesXPos, y: -20, width: self.timelineView.frame.width * fragment, height: self.timelineView.frame.height)
    }
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!)
    {
        print("didStartRecordingToOutputFileAtURL")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!)
    {
        print("didFinishRecordingToOutputFileAtURL, error: \(error)")
        recordedVideoUrl = outputFileURL
        recordingDone = true
        saveButton.hidden = false
        redoButton.hidden = false
        
        self.localVideoUrls.append(outputFileURL)
        let durationBeforeRecording = self.videoDuration
        self.reloadVideoPlayer()
        self.setMusicOffset(durationBeforeRecording)
    }
    
    @IBAction func saveRecording(sender: AnyObject) {
        if let recordedVideoUrl = recordedVideoUrl {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            guard let docDirectory = paths[0] as String? else
            {
                return
            }
            let asset = AVURLAsset(URL: recordedVideoUrl)
            let thumbnailGenerator = AVAssetImageGenerator(asset: asset)
            thumbnailGenerator.appliesPreferredTrackTransform = true
            var thumbnailFile: PFFile? = nil
            if let image = try? thumbnailGenerator.copyCGImageAtTime(asset.duration, actualTime: nil) {
                var uiImage = UIImage(CGImage: image)
                //Crop image to square
                let squareSize = min(Double(uiImage.size.width),Double(uiImage.size.height))
                uiImage = ImageCropper.cropToBounds(uiImage, width: squareSize, height: squareSize)
                if let imageData = UIImagePNGRepresentation(uiImage) {
                    thumbnailFile = PFFile(name: "thumb.png", data: imageData)
                }
            }
            if let thumbnailFile = thumbnailFile {
                thumbnailFile.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        print("Uploading of thumbnail done!")
                        
                    }
                    }, progressBlock: {
                        (percentDone: Int32) -> Void in
                        
                        print("Uploading thumbnail: \(percentDone)%")
                })
            }
            
            momentTag?["thumbnail"] = thumbnailFile
            momentTag?.ACL?.publicWriteAccess = true
            momentTag?.ACL?.publicReadAccess = true
            
            momentTag?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                
                print("moment tag saved,success: \(success) error: \(error)")
            })
            
            //let path = "\(docDirectory)/square.mp4"
            //let url = NSURL(fileURLWithPath: path)
            //VideoCropper.cropSquareVideo(outputFileURL, outputUrl: url) { (result) in
            let videoFile = PFFile(name: recordedVideoUrl.lastPathComponent, data: NSData(contentsOfURL: recordedVideoUrl)!)
            let video = PFObject(className: "MomentVideo")
            video["videoFile"] = videoFile
            //TODO: Spotify name
            video["contributor"] = "hacker"
            video["parent"] = momentTag!
            
            videoFile!.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                if succeeded {
                    print("Uploading done!")
                    
                }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    
                    print("Uploading video: \(percentDone)%")
            })
            
            video.saveInBackgroundWithBlock( { (succeeded: Bool, error: NSError?) in
                print("saved video info \(video.objectId)")
            })
        }
        
        performSegueWithIdentifier("backToDiscover", sender: self)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        //TODO: Return
        //performSegueWithIdentifier("unwindSegue1", sender: self)
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}