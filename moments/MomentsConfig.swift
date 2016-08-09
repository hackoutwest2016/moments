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
        static let clientID = "f51e1e2a1bad4bbfaa3350f7472696d7"
        static let redirectURL = "moments-login://callback"
    }
    struct parse {
        static let applicationId = "moments-hackoutwest"
        static let clientKey = ""
        static let server = "http://moments.simphax.com:4554/parse"
    }
}