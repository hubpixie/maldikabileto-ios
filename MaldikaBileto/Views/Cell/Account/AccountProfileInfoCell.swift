//
//  AccountLogoutCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/21.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class AccountProfileInfoCell: UITableViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let border = self.addBorder(toSide: .bottom, withColor: UIColor.lightGray, andThickness: 2)
        border.frame = CGRect(x: border.frame.origin.x + 2, y: border.frame.origin.y, width: border.frame.width, height: border.frame.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
