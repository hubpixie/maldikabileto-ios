//
//  CheckButton.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

@objc protocol CheckButtonDelegate {
    @objc optional func checkButton(checkButton: CheckButton, checked: Bool)
}

class CheckButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // MARK: - Private properties -
    private let checkedImage = UIImage(named: "ico_check_on")
    private let uncheckedImage = UIImage(named: "ico_check_off")
    
    // MARK: - Public properties -
    
    var delegate: CheckButtonDelegate?

    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.setTitle("", for: .normal)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            // call delegate mothod
            isChecked = !isChecked
            self.delegate?.checkButton?(checkButton: self, checked: isChecked)
        }
    }
}
