//
//  UILabel+Attribute.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

extension UILabel {
    func setBottomBorder() {
        
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
