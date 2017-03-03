//
//  DiscardViewCell.swift
//  GrubHound
//
//  Created by Umar Farooque on 19/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit

class DiscardViewCell: UITableViewCell {

    //MARK: OUTLETS
    @IBOutlet weak var dateStr: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(dataModel:DiscardModel) -> DiscardViewCell {
        
        self.dateStr.text = dataModel.dDateStr
        self.name.text = dataModel.dName
        self.address.text = dataModel.dAddress
        return self
    }
}
