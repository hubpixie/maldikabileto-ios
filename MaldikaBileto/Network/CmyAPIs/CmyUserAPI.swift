//
//  CmyUserAPI.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation
import Alamofire
import SwaggerClient

class CmyUserAPI {
    /**
     ユーザー取得
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getUser(completion: @escaping ((_ data: User?,_ error: Error?) -> Void)) {
        getUserWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     MaldikaBiletoユーザー情報取得
     - GET /client/user
     - #### 処理概要 * ユーザーの検索は、Firebaseの識別子(ユーザーUID)で行うため、GETパラメータにuser_id等は不要 * Firebaseに存在するユーザーが、MaldikaBiletoDBにも存在するか検索する(存在しなければ404を返す)
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - returns: RequestBuilder<User>
     */
    open class func getUserWithRequestBuilder() -> RequestBuilder<User> {
        let path = "/client/user"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<User>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    

    /**
     MaldikaBiletoユーザー登録
     
     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func registerUser(body: UserForAdd? = nil, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        registerUserWithRequestBuilder(body: body).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }


    /**
     MaldikaBiletoユーザー登録
     - POST /client/user
     - #### 処理概要 * すでにユーザが登録されていないかチェック(登録されている場合は409を返す) * MaldikaBiletoDBにユーザを登録する * ベリトランス側にアカウントを作成する(AccountAddRequestDto)
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter body: (body)  (optional)
     
     - returns: RequestBuilder<Void>
     */
    open class func registerUserWithRequestBuilder(body: UserForAdd? = nil) -> RequestBuilder<Void> {
        let path = "/client/user"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        //let parameters = String(data: try! JSONEncoder().encode(body), encoding: String.Encoding.utf16)

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }

    /**
     MaldikaBiletoユーザー情報変更
     
     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func updateUser(body: UserForUpdate? = nil, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        updateUserWithRequestBuilder(body: body).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }


    /**
     MaldikaBiletoユーザー情報変更
     - PUT /client/user
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * MaldikaBiletoDBのユーザー情報を更新する(電話番号、生年月日、性別、ニックネーム、FCMトークン) * Firebaseの情報を更新する(メールアドレス)※パスワードはクライアント側で更新してください * メールアドレス変更時は、Firebaseの情報を更新し、メールアドレス変更確認メールをユーザーに送信する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter body: (body)  (optional)
     
     - returns: RequestBuilder<Void>
     */
    open class func updateUserWithRequestBuilder(body: UserForUpdate? = nil) -> RequestBuilder<Void> {
        let path = "/client/user"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)

        let url = URLComponents(string: URLString)

        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true )
    }
    
    /**
     MaldikaBiletoユーザー退会
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func deleteUser(completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        deleteUserWithRequestBuilder().execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    /**
     MaldikaBiletoユーザー退会
     - DELETE /client/user
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * 対象ユーザーのチケットに未使用のチケットがないかチェック(あれば412を返す) * ベリトランス側のアカウントを削除する(AccountDeleteRequestDto) * Firebase側のユーザーを削除する * MaldikaBiletoDBからユーザを削除(論理削除)する
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - returns: RequestBuilder<Void>
     */
    open class func deleteUserWithRequestBuilder() -> RequestBuilder<Void> {
        let path = "/client/user"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()
        
        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
    /**
     チケット発行許可状態取得

     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getTicketIssuePermission(completion: @escaping ((_ result: TicketIssuePermission?,_ error: Error?) -> Void)) {
        getTicketIssuePermissionWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     チケット発行許可状態取得
     - GET /client/user/ticket-issue-permission
     - #### 処理概要 * MaldikaBiletoDBにユーザーが存在するかチェック(存在しなければ404を返す) * Firebaseに登録されたメールユーザのメールアドレス承認状態を返す * SNSログインユーザ(メールユーザではない)の場合は、メールアドレス承認状態は見ずに、trueを返す
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - returns: RequestBuilder<Any>
     */
    open class func getTicketIssuePermissionWithRequestBuilder() -> RequestBuilder<TicketIssuePermission> {
        let path = "/client/user/ticket-issue-permission"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<TicketIssuePermission>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}
