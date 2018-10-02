//
//  UITextField+Security.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/16.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

extension UITextField {
    // When toggling to secure text, all text will be purged if the user
    // continues typing unless we intervene. This is prevented by first
    // deleting the existing text and then recovering the original text.
    func togglePasswordVisibility() {
        isSecureTextEntry = !isSecureTextEntry
        
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
    }
    
    // make a given view shake
    //
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        self.layer.add(animation, forKey: "shake")
    }
}
