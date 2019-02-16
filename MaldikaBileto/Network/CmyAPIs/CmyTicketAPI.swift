//
//  CmyTicketAPI.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/20.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwaggerClient

class CmyTicketAPI {
    /**
     チケット削除
     - parameter ticketNumber: (path) チケット番号
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func deleteTicket(ticketNumber: String, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        deleteTicketWithRequestBuilder(ticketNumber: ticketNumber).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    /**
     チケット削除
     - parameter ticketNumber: (path) チケット番号
     - returns: Promise<Void>
     */
    class func deleteTicket(ticketNumber: String) -> Promise<Void> {
        let deferred = Promise<Void>.pending()

        deleteTicket(ticketNumber: ticketNumber) {(data, error) in
            if let error = error {
                deferred.resolver.reject(error)
            } else {
                deferred.resolver.fulfill(data!)
            }
        }
        return deferred.promise
    }
    
    /**
     チケット削除
     - DELETE /client/ticket/{ticket_number}
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * 対象のチケットが削除可能か(未使用か)チェック。未使用でなければ406を返す * 対象ユーザのチケットを削除(論理削除)する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter ticketNumber: (path) チケット番号
     
     - returns: RequestBuilder<Void>
     */
    class func deleteTicketWithRequestBuilder(ticketNumber: String) -> RequestBuilder<Void> {
        var path = "/client/ticket/{ticket_number}"
        let ticketNumberPreEscape = "\(ticketNumber)"
        let ticketNumberPostEscape = ticketNumberPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{ticket_number}", with: ticketNumberPostEscape, options: .literal, range: nil)
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true )
    }

//    /**
//     * enum for parameter ticketAmount
//     */
//    public enum _getPreviewTicket: Int {
//    }
    
//    /**
//     * enum for parameter ticketExpirationDate
//     */
//    public enum _getPreviewTicket: Date {
//    }
    
//    /**
//     * enum for parameter ticketTitle
//     */
//    public enum _getPreviewTicket: String {
//    }
    
    /**
     プレビュー用チケット画像取得
     
     - parameter ticketAmount: (query) チケットの金額 (optional)
     - parameter ticketExpirationDate: (query) チケットの有効期限日 (optional)
     - parameter ticketTitle: (query) チケットのタイトル (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getPreviewTicket(ticketAmount: Int? = nil, ticketExpirationDate: String? = nil, ticketTitle: String? = nil, completion: @escaping ((_ data: TicketPreviewImageData?,_ error: Error?) -> Void)) {
        getPreviewTicketWithRequestBuilder(ticketAmount: ticketAmount, ticketExpirationDate: ticketExpirationDate, ticketTitle: ticketTitle).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     プレビュー用チケット画像取得
     - GET /client/ticket-preview
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * プレビュー用のダミーQRコードを含んだチケット画像を取得する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter ticketAmount: () チケットの金額 (optional)
     - parameter ticketExpirationDate: () チケットの有効期限日 (optional)
     - parameter ticketTitle: () チケットのタイトル (optional)
     
     - returns: RequestBuilder<Any>
     */
        class func getPreviewTicketWithRequestBuilder(ticketAmount: Int? = nil, ticketExpirationDate: String? = nil, ticketTitle: String? = nil) -> RequestBuilder<TicketPreviewImageData> {
            let path = "/client/ticket-preview"
            let URLString = CmyAPIClient.webApiPath + path
            let parameters: [String:Any]? = nil
            
            var url = URLComponents(string: URLString)
            url?.queryItems = APIHelper.mapValuesToQueryItems([
                "ticket_amount": ticketAmount,
                "ticket_expiration_date": ticketExpirationDate,
                "ticket_title": ticketTitle
                ])
            
            let requestBuilder: RequestBuilder<TicketPreviewImageData>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
            
            return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
        }
        
    
        /**
         チケット取得
         
         - parameter ticketNumber: (path) チケット番号
         - parameter completion: completion handler to receive the data and the error objects
         */
        class func getTicket(ticketNumber: String, completion: @escaping ((_ data: Ticket?,_ error: Error?) -> Void)) {
            getTicketWithRequestBuilder(ticketNumber: ticketNumber).execute { (response, error) -> Void in
                completion(response?.body, error)
            }
        }
        
        
    /**
     チケット詳細取得
     - GET /client/ticket/{ticket_number}
     - #### 処理概要 * 対象のチケット番号のチケットを1件取得する * チケット画像を生成し、画像を返す * 使用済みチケットの場合は、チケット画像ではなく、レシート画像を返す
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter ticketNumber: (path) チケット番号
     
     - returns: RequestBuilder<Ticket>
     */
        class func getTicketWithRequestBuilder(ticketNumber: String) -> RequestBuilder<Ticket> {
            var path = "/client/ticket/{ticket_number}"
            let ticketNumberPreEscape = "\(ticketNumber)"
            let ticketNumberPostEscape = ticketNumberPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            path = path.replacingOccurrences(of: "{ticket_number}", with: ticketNumberPostEscape, options: .literal, range: nil)
            let URLString = CmyAPIClient.webApiPath + path
            let parameters: [String:Any]? = nil
            
            let url = URLComponents(string: URLString)
            
            let requestBuilder: RequestBuilder<Ticket>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
            
            return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
        }

    /**
     チケット一覧取得
     
     - parameter filter: (query) フィルタ  (0:すべて, 1:未使用, 2:決済失敗, 3:使用済, 4:期限切れ, 5:自分で使用)
     - parameter sort: (query) ソート項目  (ticket_type:チケット種別, ticket_status:チケットステータス, ticket_amount:チケット金額, ticket_expiration_date:チケット有効期限日, created_at:チケット作成日時, updated_at:チケット更新日時, deleted_at:チケット削除日時)
     - parameter order: (query) ソート順  (asc:昇順, desc:降順)
     - parameter page: (query) 現在ページ数 (optional)
     - parameter limit: (query) 取得最大件数 (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getTicketList(filter: Int, sort: String, order: String, page: Int? = nil, limit: Int? = nil, completion: @escaping ((_ data: TicketList?,_ error: Error?) -> Void)) {
        getTicketListWithRequestBuilder(filter: filter, sort: sort, order: order, page: page, limit: limit).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }

    /**
     チケット一覧取得
     - GET /client/ticket
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * 対象ユーザーに紐づくチケットをすべて取得する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter filter: () フィルタ  (0:すべて, 1:未使用, 2:決済失敗, 3:使用済, 4:期限切れ, 5:自分で使用)
     - parameter sort: () ソート項目  (ticket_type:チケット種別, ticket_status:チケットステータス, ticket_amount:チケット金額, ticket_expiration_date:チケット有効期限日, created_at:チケット作成日時, updated_at:チケット更新日時, deleted_at:チケット削除日時)
     - parameter order: () ソート順  (asc:昇順, desc:降順)
     - parameter page: () 現在ページ数 (optional)
     - parameter limit: () 取得最大件数 (optional)
     
     - returns: RequestBuilder<TicketList>
     */
    class func getTicketListWithRequestBuilder(filter: Int, sort: String, order: String, page: Int? = nil, limit: Int? = nil) -> RequestBuilder<TicketList> {
        let path = "/client/ticket"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "filter": filter,
            "sort": sort,
            "order": order,
            "page": page,
            "limit": limit
            ])
        
        let requestBuilder: RequestBuilder<TicketList>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true )
    }

    /**
     チケット発行
     
     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func publishTicket(body: TicketForAdd? = nil, completion: @escaping ((_ data: TicketImageData?,_ error: Error?) -> Void)) {
        publishTicketWithRequestBuilder(body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     チケット発行
     - POST /client/ticket
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * チケット発行権限があるかのチェックを行う   * メールユーザーかつ、メール認証が済んでいない場合で、その他SNS認証なしの場合は406を返す * クレジットカードの存在チェックを行う * チケット番号を生成する   * MaldikaBiletoDB内に登録されているチケット番号と重複した場合は、3回まで再生成する   * 3回繰り返しても重複してしまう場合は409を返す(イレギュラー) * 対象ユーザーのチケットを登録する * チケット画像を生成し、画像を返す
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter body: (body)  (optional)
     
     - returns: RequestBuilder<Any>
     */
    open class func publishTicketWithRequestBuilder(body: TicketForAdd? = nil) -> RequestBuilder<TicketImageData> {
        let path = "/client/ticket"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<TicketImageData>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true )
    }

}
