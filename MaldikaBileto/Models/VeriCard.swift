//
//  VeriCard.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

public struct VeriCard: Codable {
    
    /** [Veritrans要求]  API key。  */
    public var tokenApiKey: String

    /** [Veritrans要求]  決済サーバーにて付与されたカードIDが  */
    public var cardNumber: String
    
    /** [Veritrans要求]  MM/YY形式 有効期間  */
    public var cardExpire: String

    /** [Veritrans要求]  セキュリティコード  */
    public var securityCode: String

    /** [Veritrans要求]  使用言語  */
    public var lang: String
    
    
    public init(cardNumber: String, cardExpire: String, securityCode: String) {
        self.tokenApiKey = CmyAPIClient.veriTransApiKey
        self.cardNumber = cardNumber
        self.cardExpire = cardExpire
        self.securityCode = securityCode
        self.lang = "ja"
    }


    public enum CodingKeys: String, CodingKey {
        case tokenApiKey = "token_api_key"
        case cardNumber = "card_number"
        case cardExpire = "card_expire"
        case securityCode = "security_code"
        case lang = "lang"
    }
}
