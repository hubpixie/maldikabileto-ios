//
//  EmailApprovalState.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

public struct TicketIssuePermission: Codable {
    
    
    /** チケット発行許可承認状態 */
    public var permission: Bool
    
    public init(permission: Bool) {
        self.permission = permission
    }
    
    
}
