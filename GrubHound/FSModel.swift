//
//  FSModel.swift
//  GrubHound
//
//  Created by Umar Farooque on 17/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

/*
 
 THIS CLASS IS USED FOR PARSING THE RESPONSE INTO MODELS
 
 */


import UIKit

class FSModel: NSObject {
    
    //MARK: Trending cell vars
    var elementID : String! = ""
    var placeName : String! = ""
    var placeAddress : String! = ""
    var placeDistance : Int! = 0
    var placeCategoryID : String! = ""
    var placeIcons : String! = ""
    var placeUserCount : Int! = 0
    var placeCheckinCount : Int! = 0
    var placeRating: String! = ""
    var placeRatingColor : String! = ""
        
    //MARK: Detail vars
    var detailID : String = ""
    var detailPricing : String = "₹"
    var detaingRating : String = "-"
    var detailReviews : String = "-"
    var detailNumber : String = ""
    var detailAddress : String = ""
    var detailShareStr : String = ""
    var detailName : String = ""
    var detailDistance : Int! = 0
    var detailCategoryID : String = ""
    var detailplaceIcons : String = ""
    var detailUserCount : Int! = 0
    var detailCheckinCount : Int! = 0
    var detailImgURL : String! = ""
    var detailImgArr : [String] = [""]
    

    //MARK: used by Trending View Controller
    init(data:[String:Any]) {
        super.init()
        self.elementID = data["id"] as? String ?? ""
        self.placeName = data["name"] as? String ?? ""
        let ratingData = data["rating"] as? Float ?? 0.0
        self.placeRating = String(format: "%.1f", ratingData)
        self.placeRatingColor = data["ratingColor"] as? String ?? ""
        let addressDict = ((data["location"]  as? CustomDict) ?? ["":""])
        if addressDict["formattedAddress"] != nil {

            let addressArray = (addressDict["formattedAddress"]) as? [String] ?? [""]
            if addressArray.first?.characters.count ?? 0 > 0 {
                //address present
                var completeAddressStr = ""
                for addStr in addressArray {
                    completeAddressStr = "\(completeAddressStr)\n\(addStr)"
                }
                self.placeAddress = completeAddressStr
            }

        }
        self.placeDistance = ((data["location"]  as? CustomDict) ?? ["":""])["distance"] as? Int ?? 0
        let categoryDataArr = (data["categories"]  as? [CustomDict] ?? [["":""]])
        var categoryObj = categoryDataArr.first
        if categoryObj != nil && categoryObj?["id"] != nil {
            
            let categoryIdStr = categoryObj!["id"] as? String ?? ""
            self.placeCategoryID = categoryIdStr
            
        }
        
        let iconDataArr = (data["categories"]  as? [CustomDict] ?? [["":""]])
        var iconObj = iconDataArr.first
        if iconObj != nil && iconObj?["icon"] != nil {
            
            let iconDict = iconObj!["icon"] as? CustomDict ?? ["":""]
            var iconURLStr = iconDict["prefix"] as? String ?? ""
            iconURLStr = "\(iconURLStr)bg_88\(iconDict["suffix"] as? String ?? "")"
            self.placeIcons = iconURLStr
        }
        let statDict = data["stats"] as? CustomDict ?? ["":""]
        if statDict["checkinsCount"] != nil {
            
            self.placeCheckinCount = statDict["checkinsCount"] as? Int ?? 0
            self.placeUserCount = statDict["usersCount"] as? Int ?? 0
        }
    }
    
    
    //MARK: used by Detail View Controller
    init(withDetailDict:[String:Any]) {
        super.init()
        if withDetailDict["contact"] as? CustomDict != nil {
            
            let contactDict = withDetailDict["contact"] as! CustomDict
            let number = contactDict["phone"] as? String
            self.detailNumber = number ?? ""
        }
        if withDetailDict["shortUrl"] as? String != nil {
            
            self.detailShareStr = withDetailDict["shortUrl"] as! String
        }
        self.detailID = withDetailDict["id"] as? String ?? ""
        self.detailName = withDetailDict["name"] as? String ?? ""
        let addressDict = ((withDetailDict["location"]  as? CustomDict) ?? ["":""])
        if addressDict["formattedAddress"] != nil {
            
            let addressArray = (addressDict["formattedAddress"]) as? [String] ?? [""]
            if addressArray.first?.characters.count ?? 0 > 0 {
                
                //address present
                var completeAddressStr = ""
                for addStr in addressArray {
                    completeAddressStr = "\(completeAddressStr)\n\(addStr)"
                }
                self.detailAddress = "\(completeAddressStr)\n"
            }
            
        }
        self.detailDistance = ((withDetailDict["location"]  as? CustomDict) ?? ["":""])["distance"] as? Int ?? 0
        let categoryDataArr = (withDetailDict["categories"]  as? [CustomDict] ?? [["":""]])
        var categoryObj = categoryDataArr.first
        if categoryObj != nil && categoryObj?["id"] != nil {
            let categoryIdStr = categoryObj!["id"] as? String ?? ""
            self.detailCategoryID = categoryIdStr
        }
        let iconDataArr = (withDetailDict["categories"]  as? [CustomDict] ?? [["":""]])
        var iconObj = iconDataArr.first
        if iconObj != nil && iconObj?["icon"] != nil {
            
            let iconDict = iconObj!["icon"] as? CustomDict ?? ["":""]
            var iconURLStr = iconDict["prefix"] as? String ?? ""
            iconURLStr = "\(iconURLStr)\(64)\(iconDict["suffix"] as? String ?? "")"
            self.detailplaceIcons = iconURLStr
        }
        
        let statDict = withDetailDict["stats"] as? CustomDict ?? ["":""]
        if statDict["checkinsCount"] != nil {
            self.detailCheckinCount = statDict["checkinsCount"] as? Int ?? 0
            self.detailUserCount = statDict["usersCount"] as? Int ?? 0
        }
        
        let pricing = withDetailDict["attributes"] as? CustomDict ?? ["":""]
        if pricing["groups"] as? [CustomDict] != nil {
            
            let pricingGroup = pricing["groups"] as? [CustomDict] ?? [["":""]]
            if pricingGroup.count > 0 {
                let priceGroupArr = pricingGroup[0]
                if priceGroupArr["summary"] as? String != nil {
                    
                    self.detailPricing = priceGroupArr["summary"] as! String
                }
            }
            
        }else if pricing["groups"] as? [Any] != nil {
            self.detailPricing = "-"
        }
        
        let rating = withDetailDict["rating"] as? Float ?? 0
        if rating == 0 {
            self.detaingRating = "-"
        }else{
            self.detaingRating = "\(rating)"
        }
        let ratingSignals = withDetailDict["ratingSignals"] as? Int ?? 0
        if ratingSignals == 0 {
            self.detailReviews = "-"
            
        }else{
            self.detailReviews = "\(ratingSignals)"
        }
    
        if withDetailDict["photos"] != nil {
            let photoDataGroup = withDetailDict["photos"] as? CustomDict ?? ["":""]
            if photoDataGroup["groups"] != nil {
                let photoDataGroupArr = photoDataGroup["groups"] as? [Any] ?? [""]
                for obj in photoDataGroupArr {
                    
                    let itemObj = obj as? CustomDict ?? ["":""]
                    if itemObj["items"] != nil {
                        let itemArr = itemObj["items"] as? [Any] ?? [""]
                        for items in itemArr {
                            
                            let itemsObj = items as? CustomDict ?? ["":""]
                            if itemsObj["prefix"] != nil {
                                
                                let imgPrefix = itemsObj["prefix"] as! String
                                let imgSuffix = itemsObj["suffix"] as! String
                                let width = itemsObj["width"] as? Int ?? 0
                                var imgDownloadURL = ""
                                if width < 300 && width > 100 {
                                    
                                    imgDownloadURL = "\(imgPrefix)250\(imgSuffix)"
                                    
                                }else if width < 400 && width > 300 {
                                    
                                    imgDownloadURL = "\(imgPrefix)350\(imgSuffix)"
                                    
                                    
                                }else if width < 500 && width > 400{
                                    
                                    imgDownloadURL = "\(imgPrefix)450\(imgSuffix)"
                                    
                                    
                                }else if width < 600 && width > 500{
                                    
                                    imgDownloadURL = "\(imgPrefix)550\(imgSuffix)"
                                    
                                    
                                }else if width < 700 && width > 600{
                                    
                                    imgDownloadURL = "\(imgPrefix)650\(imgSuffix)"
                                    
                                    
                                }else {
                                    
                                    imgDownloadURL = "\(imgPrefix)750\(imgSuffix)"

                                }
                                self.detailImgArr.append(imgDownloadURL)
                            }
                        }
                    }
                }
            }
        }
    }
}
