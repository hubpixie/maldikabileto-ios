//
//  File.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/25.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

infix operator =~
infix operator !~

// 正規表現使用時の簡素化
//
func =~(lhs: String, rhs: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: rhs,
                                               options: NSRegularExpression.Options()) else {
                                                return false
    }
    
    return regex.numberOfMatches(in: lhs,
                                 options: NSRegularExpression.MatchingOptions(),
                                 range: NSRange(location: 0, length: lhs.count)) > 0
}

func !~(lhs: String, rhs: String) -> Bool {
    return !(lhs=~rhs)
}

// 文字列から日付へ変換する
//
extension String {
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.date(from: self)
    }
    func convertToDateWithYYYYMD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'M'-'d'"
        return dateFormatter.date(from: self)
    }
    
    static func replacingInsertingAtRange(_ range: NSRange, of text: String?, with subSting: String) -> String {
        var retStr = ""
        if let text = text as NSString? {
            if subSting.count > 0 {
                retStr = text.substring(to: range.location) + subSting + ((text.length >= range.location) ?  text.substring(from: range.location) : "")
            } else {
                retStr = text.replacingCharacters(in: range, with: subSting)
            }
        }
        return retStr
    }
}

// カンマ処理
//
extension String {
    static func formatCurrencyString(number: Int) -> String? {
        let  formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        return formatter.string(from: number as NSNumber)
    }
}

// 文字列表示時の縦幅と横幅を計算する
//
extension String {
    
    func getTextSize(font:UIFont, viewWidth:CGFloat, padding:CGFloat) -> CGSize {
        var size = CGSize.zero
        
        if let s:CGSize = self.makeSize(width: viewWidth, font: font) {
            size = CGSize(width: s.width, height: s.height + padding)
        }
        return size
    }
    
    func makeSize(width:CGFloat, font:UIFont) -> CGSize? {
        var size:CGSize = CGSize.zero
        
        let bounds:CGSize = CGSize(width: width, height: CGFloat.infinity)
        let attributes: Dictionary = [NSAttributedStringKey.font: font]
        let options = unsafeBitCast(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.usesFontLeading.rawValue, to: NSStringDrawingOptions.self)
        
        let rect:CGRect = self.boundingRect(with: bounds, options: options, attributes: attributes, context: nil)
        size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
    }
}


