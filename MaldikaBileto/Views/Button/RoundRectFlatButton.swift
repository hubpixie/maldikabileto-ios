//
//  RoundRectFlatButton.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class RoundRectFlatButton: UIButton {

    var selectedState: Bool = false
    
    var colorsChangedForBorderAndTint: UIColor = UIColor(displayP3Red: 0xF3/0xFF, green: 0x98/0xFF, blue: 0x00, alpha: 1.0) {
        didSet {
            self.layer.borderColor = colorsChangedForBorderAndTint.cgColor
            self.setTitleColor(colorsChangedForBorderAndTint, for: .normal)
            self.setTitleColor(colorsChangedForBorderAndTint.withAlphaComponent(0.5), for: .disabled)
            //self.layoutSubviews()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 6 / UIScreen.main.nativeScale
        layer.borderColor = UIColor.cmyMainColor().cgColor
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        //color
        backgroundColor = UIColor.white
        self.setTitleColor(UIColor.cmyMainColor().withAlphaComponent(0.7), for: .disabled)
        self.setTitleColor(UIColor.cmyMainColor(), for: .normal)
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        //layer
        layer.cornerRadius = frame.height / 2
        
        //font
        let fontSize = self.titleLabel?.font.pointSize
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize!)
    }
}
