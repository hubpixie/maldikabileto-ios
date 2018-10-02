//
//  CardInfoTableCell.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/21.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class CardInfoTableCell: UITableViewCell {

    @IBOutlet weak var defaultCardLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // if 4-inch device, make font size smaller for Facebook/google login button
        if UIScreen.main.bounds.width <= 320 {
            self.cardNumberLabel.font = UIFont.systemFont(ofSize: self.cardNumberLabel.font.pointSize - 6)
        } else if UIScreen.main.bounds.width <= 420 {
            self.cardNumberLabel.adjustsFontSizeToFitWidth = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
