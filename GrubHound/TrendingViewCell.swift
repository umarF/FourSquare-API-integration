//
//  TrendingViewCell.swift
//  GrubHound
//
//  Created by Umar Farooque on 17/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit

class TrendingViewCell: UITableViewCell {

    //MARK: OUTLETS
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(dataModel:FSModel) -> TrendingViewCell{
        nameLabel.text = dataModel.placeName!
        descLabel.text = dataModel.placeAddress!
        if dataModel.placeDistance != 0 {
            distanceLabel.text = "\(dataModel.placeDistance!/1000) Km away"
        }else{
            distanceLabel.text = "\(dataModel.placeDistance!) Km away"
        }
        checkLabel.text = "\(dataModel.placeRating!)"
        if dataModel.placeRatingColor.characters.count > 2 {
            checkLabel.textColor = hexStringToUIColor(hex: dataModel.placeRatingColor!)
        }else{
            checkLabel.textColor = UIColor.red
        }
        return self
    }
}
