//
//  ReviewModel.swift
//  GrubHound
//
//  Created by Umar Farooque on 17/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import RealmSwift

//MARK: Realm Models
class ReviewModel: Object {

    dynamic var rID = ""
    dynamic var rText = ""
    dynamic var rVenueName = ""
    dynamic var rDateStr = ""
    dynamic var rStar = ""
}

class DiscardModel: Object {
    
    dynamic var dID = ""
    dynamic var dDateStr = ""
    dynamic var dName = ""
    dynamic var dAddress = ""
}


