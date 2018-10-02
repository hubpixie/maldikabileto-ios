//
//  VeriTransAPI.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation
import Alamofire
import SwaggerClient

class VeriTransAPI {
    /**
     チケット取得
     
     - parameter ticketId: (path) チケットID
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getCardMdkToken(body: VeriCard? = nil, completion: @escaping ((_ data: VeriMdkToken?,_ error: Error?) -> Void)) {
        getCardMdkTokenWithRequestBuilder(body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    

    /**
     チケット取得
     - GET /client/ticket/{ticket_id}
     - #### 処理概要  * 対象ユーザに紐づくチケットをすべて取得する  * QRコードを生成し、画像を返す
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter ticketId: (path) チケットID
     
     - returns: RequestBuilder<Ticket>
     */
    open class func getCardMdkTokenWithRequestBuilder(body: VeriCard? = nil) -> RequestBuilder<VeriMdkToken> {
        let path = "/4gtoken"
        let URLString = CmyAPIClient.veriTransApiPath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<VeriMdkToken>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }


}
