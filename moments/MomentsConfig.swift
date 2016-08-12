//
//  MomentsConfig.swift
//  moments
//
//  Created by Simon Nilsson on 2016-08-09.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//

import Foundation
struct MomentsConfig {
    struct spotify {
        static let clientId = "f51e1e2a1bad4bbfaa3350f7472696d7"
        static let redirectUrl = "moments-login://callback"
    }
    struct parse {
        static let applicationId = "moments-hackoutwest"
        static let clientKey = ""
        static let server = "http://moments.simphax.com:4554/parse"
    }
    struct mapbox {
        static let styleUrl = "mapbox://styles/heddao/cirnd85rm000fgzni87petcp9"
    }
    static let colors = [
        UIColor(red:0.97, green:0.26, blue:0.66, alpha:1.0),
        UIColor(red:0.00, green:0.76, blue:0.95, alpha:1.0),
        UIColor(red:0.28, green:0.05, blue:0.56, alpha:1.0),//purple
        UIColor(red:0.06, green:0.81, blue:0.64, alpha:1.0)//green
    ]
    
    static let yellow = UIColor(red:1.00, green:0.91, blue:0.38, alpha:1.0)//yellow
    
}

struct Palette{
    static let purple = UIColor(red:0.40, green:0.21, blue:0.58, alpha:1.0)
}

class Song {
    let artist:String
    let name:String
    let link:String
    
    init(artist: String, name: String,link: String) {
        self.artist = artist
        self.name = name
        self.link = link
    }
}