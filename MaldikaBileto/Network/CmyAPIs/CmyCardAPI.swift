//
//  CmyCardAPI.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation
import Alamofire
import SwaggerClient

class CmyCardAPI {
    /**
     クレジットカード登録
     
     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func addCard(body: CardForAdd? = nil, completion: @escaping ((_ data: Card?,_ error: Error?) -> Void)) {
        addCardWithRequestBuilder(body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     クレジットカード登録
     - POST /client/card
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * すでに登録済みのカードを登録しようとした場合は409を返す * ベリトランスにカード情報を登録
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter body: (body)  (optional)
     
     - returns: RequestBuilder<Card>
     */
    open class func addCardWithRequestBuilder(body: CardForAdd? = nil) -> RequestBuilder<Card> {
        let path = "/client/card"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)

        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Card>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
    
    /**
     標準クレジットカード変更
     - PUT /client/card/{card_id}
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * ベリトランスに登録済みのカードの「標準カードフラグ」を変更する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter cardId: (path) カードID
     
     - returns: RequestBuilder<Void>
     */
    open class func changeDefaultCard(cardId: String, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        changeDefaultCardWithRequestBuilder(cardId: cardId).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    /**
     標準クレジットカード変更
     - PUT /client/card/{card_id}
     - #### 処理概要  * ベリトランスに登録済みのカードの「標準カードフラグ」を変更する
     
     - parameter cardId: (path) カードID
     
     - returns: RequestBuilder<Void>
     */
    open class func changeDefaultCardWithRequestBuilder(cardId: String) -> RequestBuilder<Void> {
        var path = "/client/card/{card_id}"
        let cardIdPreEscape = "\(cardId)"
        let cardIdPostEscape = cardIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{card_id}", with: cardIdPostEscape, options: .literal, range: nil)
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
    
    /**
     クレジットカード削除
     - DELETE /client/card/{card_id}
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * 対象ユーザーの未使用チケットを全て削除する * 対象ユーザーのクレジットカード情報を、ベリトランスから削除する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter cardId: (path) カードID
     
     - returns: RequestBuilder<Void>
     */
    open class func deleteCard(cardId: String, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        deleteCardWithRequestBuilder(cardId: cardId).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    /**
     クレジットカード削除
     - DELETE /client/card/{card_id}
     - #### 処理概要  * 未使用チケットがあるかどうか確認する  * 未使用チケットが存在する場合は、クレジットカード情報削除不可  * 未使用チケットが存在する場合は、409を返し、ユーザに未使用チケットの削除を依頼する  * 未使用チケットが存在しなければ、対象ユーザのクレジットカード情報を、ベリトランスから削除する
     
     - parameter cardId: (path) カードID
     
     - returns: RequestBuilder<Void>
     */
    open class func deleteCardWithRequestBuilder(cardId: String) -> RequestBuilder<Void> {
        var path = "/client/card/{card_id}"
        let cardIdPreEscape = "\(cardId)"
        let cardIdPostEscape = cardIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{card_id}", with: cardIdPostEscape, options: .literal, range: nil)
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
    /**
     クレジットカード一覧取得
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getCardList(completion: @escaping ((_ data: CardList?,_ error: Error?) -> Void)) {
        getCardListWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     クレジットカード一覧取得
     - GET /client/card
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * ベリトランスに登録されているクレジットカード情報を全て取得する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - returns: RequestBuilder<CardList>
     */
    open class func getCardListWithRequestBuilder() -> RequestBuilder<CardList> {
        let path = "/client/card"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<CardList>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
}
