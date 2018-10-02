//
//  UITableView+ext.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/09/24.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func preventDoubleTap() {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self]() in
            self?.isUserInteractionEnabled = true
        }
    }
}
