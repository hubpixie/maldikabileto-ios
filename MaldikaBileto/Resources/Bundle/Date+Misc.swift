//
//  Date+Misc.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/21.
//  Copyright © 2018 x.yang. All rights reserved.
//

import Foundation

extension Date {
    func toLongDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return "\(formatter.string(from: self))"
    }
    func toMMYYStringWithSlash() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return "\(formatter.string(from: self))"
    }
    func toYYYYMMStringWithSlash() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        return "\(formatter.string(from: self))"
    }
    func toYYYYMMStringWithHyphen() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "\(formatter.string(from: self))"
    }
    func toYYYYMMDDStringWithHyphen() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: self))"
    }
}
