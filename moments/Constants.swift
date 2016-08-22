//
//  Constants.swift
//  moments
//
//  Created by Pak on 10/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//



enum color:Int {
    case blue, purple
    
    var mainColor: UIColor {
        switch self {
        case .blue:
            return  UIColor(red:0.22, green:0.64, blue:0.89, alpha:1.0)
        case .purple:
            return UIColor.whiteColor()
        }
        //lime: UIColor.rgb(184, green: 233, blue: 134, alpha: 1)
    }
}