//
//  VeriMdkToken.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

public struct VeriMdkToken: Codable {
    
    /** [Veritrans応答]  トークン  */
    public var token: String
    public var tokenExpireDate: String
    public var reqCardNumber: String
    public var status: String
    public var code: String
    public var message: String

    public init(token: String, tokenExpireDate: String, reqCardNumber: String, code: String, message: String) {
        self.token = token
        self.tokenExpireDate = token
        self.reqCardNumber = reqCardNumber
        self.status = token
        self.code = code
        self.message = message
    }
    
    public enum CodingKeys: String, CodingKey {
        case token = "token"
        case tokenExpireDate = "token_expire_date"
        case reqCardNumber = "req_card_number"
        case status = "status"
        case code = "code"
        case message = "message"
    }

}
