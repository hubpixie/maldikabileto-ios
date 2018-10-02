//
//  UserProfileInfoCellTableViewCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/21.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class AccountProfilePasswordCell: UITableViewCell {

    @IBOutlet weak var itemValueLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
