//
//  ReviewCell.swift
//  GrubHound
//
//  Created by Umar Farooque on 18/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {

    //MARK: OUTLETS
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(dataModel:ReviewModel) -> ReviewCell{

        self.reviewText.text = dataModel.rText
        self.reviewDate.text = dataModel.rDateStr
        self.ratingLabel.text = dataModel.rStar
        return self
    }
}
