//
//  CircleButton.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    var selectedState: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.width)
        clipsToBounds = true
        layer.borderWidth = 6 / UIScreen.main.nativeScale
        layer.borderColor = UIColor.clear.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        layer.cornerRadius = 1.0 * self.bounds.size.width
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowRadius = 2.5
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.titleLabel?.textColor = self.selectedState ? UIColor.gray : UIColor.white
    }
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self.selectedState = !selectedState
        self.layoutSubviews()
    }*/
}
