//
//  CALayer+ext.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/02.
//  Copyright © 2018年 x.yang. All rights reserved.
//
import UIKit


@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

extension UIView {
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    /*
     func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {
     
     let border = CALayer()
     switch side {
     case .left: border.frame = CGRect(x: 0, y: 0, width: thickness, height: layer.frame.height)
     case .right: border.frame = CGRect(x: layer.frame.height - thickness, y: 0, width: thickness, height: layer.frame.height)
     case .top: border.frame = CGRect(x: 0, y: 0, width: layer.frame.width, height: thickness)
     case .bottom: border.frame = CGRect(x: 0, y: layer.frame.height - thickness, width: layer.frame.width, height: thickness)
     }
     
     border.backgroundColor = color.cgColor
     layer.addSublayer(border)
     }*/
    
    func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        switch side {
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.size.height)
        case .right:
            border.frame = CGRect(x: frame.size.width - thickness, y: 0, width: thickness, height: frame.size.height)
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.size.height - thickness, width: frame.size.width, height: thickness)
        }
        addSubview(border)
        return border
    }
    
    //指定ビューの下部のみに線を引く
    func setViewBottomBorder() {
        //self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.cmyBottomBorderColor().cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }

}


extension UIView {
    // 指定ビューを回転させる
    //
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
}

extension UIView {
    /// Use safeAreaLayoutGuide on iOS 11+, otherwise default to dummy layout guide
    var compatibleSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
}
