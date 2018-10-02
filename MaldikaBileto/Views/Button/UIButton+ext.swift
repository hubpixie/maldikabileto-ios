//
//  UIButton+ext.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/09/15.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

fileprivate var _singleTapped: Bool = false
extension UIButton {
    var singleTapped: Bool {
        get {
            return _singleTapped
        }
        set(newValue) {
            self.isEnabled = newValue
            _singleTapped = newValue
        }
    }
}

