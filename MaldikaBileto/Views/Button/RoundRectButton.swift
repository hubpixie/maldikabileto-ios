//
//  RoundRectButton.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class RoundRectButton: UIButton {

    var selectedState: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 6 / UIScreen.main.nativeScale
        self.layer.borderColor = {[weak self]() in
            if (self?.isEnabled)! {
                return UIColor.cmyMainColor().withAlphaComponent(0.5).cgColor
            } else {
                return UIColor.cmyDisabledColor().withAlphaComponent(0.5).cgColor
            }
        }()
        
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        //color - normal
        self.backgroundColor = UIColor.cmyMainColor()
        self.setTitleColor(UIColor.white, for: .normal)
        
        //color - disabled
        self.setTitleColor(UIColor.white, for: .disabled)
        self.setBackgroundImage(self.image(withColor: UIColor.cmyDisabledColor()), for: .disabled)
        
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        //layer
        layer.cornerRadius = frame.height / 2
        
        //font
        let fontSize = self.titleLabel?.font.pointSize
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize!)
    }
    
    private func image(withColor color: UIColor) -> UIImage? {
        
        // 1. make a gray image
        let rect = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image == nil {return image}
        
        // 2. cut it corner as round rect.
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1)
        
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.frame.height
            ).addClip()
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

extension RoundRectButton {
    override public var isEnabled: Bool {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] () in
                
                if (self?.isEnabled)! {
                    self?.layer.borderColor = UIColor.cmyMainColor().withAlphaComponent(0.5).cgColor
                } else {
                    self?.layer.borderColor = UIColor.cmyDisabledColor().withAlphaComponent(0.5).cgColor
                }
            }
        }
    }
}
