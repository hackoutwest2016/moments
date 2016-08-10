//
//  VideoCropper.swift
//  moments
//
//  Created by Simon Nilsson on 2016-08-10.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//

import Foundation
import AVFoundation

class VideoCropper {
    static func cropSquareVideo(inputUrl: NSURL, outputUrl: NSURL, callback: (result: NSURL) -> Void) {
        
        let asset = AVAsset(URL: inputUrl)
        let clipVideoTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first!
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 60)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let t1: CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
        let t2: CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        
        let finalTransform: CGAffineTransform = t2
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.outputURL = outputUrl
        
        exporter!.exportAsynchronouslyWithCompletionHandler({
            callback(result: outputUrl)
        })
    }
}