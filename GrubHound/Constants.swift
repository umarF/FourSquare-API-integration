//
//  Constants.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

//MARK: STORYBOARD IDS
enum storyBoardID: String {
    
    case  trendingVC = "trendingVC"
    case  ratingVC = "ratingVC"
    case  discardVC = "discardVC"
    case  dashBoardVC = "dashBoardVC"
    case  trendingCell = "trendingCell"
    case  reviewCell = "reviewCell"
    case  detailVC = "detailVC"
    case ratingPop = "ratingPop"
    case ratingCell = "ratingCell"
    case discardCell = "discardCell"
    
}

//MARK: FOURSQUARE KEYS
let CLIENT_ID = "REPLACE_WITH_YOUR_CLIENT_ID"
let CLIENT_SECRET = "REPLACE_WITH_YOUR_CLIENT_SECRET"

//MARK: URL Cons
let SERVER_URL = "https://api.foursquare.com"

//MARK: OTHERS

enum CustomError: Error {
    case locationNotFound
}

struct customLocation {
    
    var lat : Double = 0.0000
    var long : Double = 0.0000
    var locationObj : CLLocation?
    
    func returnStringFormat(location:CLLocation) ->[String] {
        
        let lat = String(format: "%.2f",location.coordinate.latitude)
        let long = String(format: "%.2f",location.coordinate.longitude)
        return [lat,long]
    }
    
}

typealias CustomDict = [String:Any]
let SearchActionNotif = "SearchActionNotif"
let HideNavNotif = "HideNavNotif"
let ShowNavNotif = "ShowNavNotif"
let ReloadDetailReviewNotif = "ReloadDetailReviewNotif"
let ClearArrNotif = "ClearArrNotif"
var imageCache:NSCache = NSCache<AnyObject,AnyObject>()

//func to convert hexString To UIColor
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//get formatted date
func getCurrentDate() -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYYMMdd"
    let dateString = dateFormatter.string(from: Date())
    return dateString
    
}
