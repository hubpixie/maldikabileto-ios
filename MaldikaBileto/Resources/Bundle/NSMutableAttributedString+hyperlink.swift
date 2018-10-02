//
//  NSMutableAttributedString+link.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/04.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    func setAsLink(inText:String, linkURL:String) -> Bool {
        let foundRange = self.mutableString.range(of: inText)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
