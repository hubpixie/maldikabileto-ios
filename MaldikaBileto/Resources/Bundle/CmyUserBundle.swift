//
//  UtilityBundle.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/08/26.
//  Copyright © 2018 x.yang. All rights reserved.
//

import Foundation


class CmyUserBundle {
    
    // For Inquire
    //
    struct InquireRef {
        var inquireId: Int
        var createdAt: String
        var collapsed: Bool
        var readState: Bool
        
        static func inquireRef(from dic: Dictionary<String, Any>?) -> InquireRef {
            let inquireId = dic?["inquire_id"] as? Int ?? 0
            let createdAt = dic?["created_at"] as? String ?? ""
            let collapsed = dic?["collapsed"] as? Bool ?? false
            let readState = dic?["read_state"] as? Bool ?? false
            return InquireRef(inquireId: inquireId, createdAt: createdAt, collapsed: collapsed, readState: readState)
        }
        
        func dictionary() -> Dictionary<String, Any> {
            let dic: [String : Any] = [
                "inquire_id": self.inquireId,
                "created_at": self.createdAt,
                "collapsed": self.collapsed,
                "read_state": self.readState
            ]
            return dic
        }
    }
}
