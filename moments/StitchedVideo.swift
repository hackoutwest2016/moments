//
//  StitchedVideo.swift
//  tagify test
//
//  Created by Simon Nilsson on 2016-08-09.
//  Copyright © 2016 Simon Nilsson. All rights reserved.
//

import Foundation
import AVFoundation

class StitchedVideo {
    
    var PlayerItem: AVPlayerItem
    
    init(videoUrls: [NSURL]) {
        
        var assets = [AVAsset]()
        
        for videoUrl in videoUrls {
            assets.append(AVAsset(URL: videoUrl))
        }
        
        let mutableComposition = AVMutableComposition()
        let videoCompositionTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        //let audioCompositionTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var size = CGSizeZero
        var time = kCMTimeZero
        
        var instructions = [AVMutableVideoCompositionInstruction]()
        
        for asset in assets {
            let videoAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first!
            
            if (try? videoCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), ofTrack: videoAssetTrack, atTime: time)) == nil {
                print("ERROR in adding video track")
            }
            
            let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
            videoCompositionInstruction.timeRange = CMTimeRangeMake(time, videoAssetTrack.timeRange.duration);
            videoCompositionInstruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)]
            instructions.append(videoCompositionInstruction)
            
            time = CMTimeAdd(time, videoAssetTrack.timeRange.duration);
            if CGSizeEqualToSize(size, CGSizeZero) {
                size = videoAssetTrack.naturalSize
            }
        }
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = instructions
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        mutableVideoComposition.renderSize = size;
        
        let playerItem = AVPlayerItem(asset: mutableComposition)
        playerItem.videoComposition = mutableVideoComposition
        
        PlayerItem = playerItem
    }
}