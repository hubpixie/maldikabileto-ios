//
//  PrivacyInfoCell.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/14.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class PrivacyInfoCell: UITableViewCell {

    @IBOutlet weak var passcodeLockSwitch: UISwitch!
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
        self.passcodeLockSwitch.isOn = CmyUserDefault.shared.passcodeSetting.isValid
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func passcodeLockSwitchValueChanged(_ sender: UISwitch) {
        CmyUserDefault.shared.passcodeSetting.isValid = sender.isOn
    }
    
}
