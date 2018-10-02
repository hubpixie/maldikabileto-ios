//
//  AppSettingItemCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class AppSettingItemCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    
    var itemUrl: String?
    var segueId: CmySegueIds!

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
