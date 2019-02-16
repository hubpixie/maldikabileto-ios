//
//  CmyInquireAPI.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/15.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwaggerClient

class CmyInquireAPI {

    /**
     お知らせ一覧取得
     
     - parameter page: (query) 現在ページ数 (optional)
     - parameter limit: (query) 取得最大件数 (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    class func getInquireList(page: Int? = nil, limit: Int? = nil, completion: @escaping ((_ data: InquireList?,_ error: Error?) -> Void)) {
        getInquireListWithRequestBuilder(page: page, limit: limit).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    /**
     お知らせ一覧取得
     
     - parameter page: (query) 現在ページ数 (optional)
     - parameter limit: (query) 取得最大件数 (optional)
     
     - returns: Promise<InquireList>
     */
    class func getInquireList(page: Int? = nil, limit: Int? = nil) -> Promise<InquireList> {
        let deferred = Promise<InquireList>.pending()
        getInquireList(page: page, limit: limit) { data, error in
            if let error = error {
                deferred.resolver.reject(error)
            } else {
                deferred.resolver.fulfill(data!)
            }
        }
        return deferred.promise
    }
    

    /**
     お知らせ一覧取得
     - GET /client/inquire
     - #### 処理概要 * 有効なお知らせをすべて取得する * 一覧の順序は、作成日時の降順、固定です
     - BASIC:
     - type: http
     - name: bearerAuth
     
     - parameter page: () 現在ページ数 (optional)
     - parameter limit: () 取得最大件数 (optional)
     
     - returns: RequestBuilder<InquireList>
     */
    class func getInquireListWithRequestBuilder(page: Int? = nil, limit: Int? = nil) -> RequestBuilder<InquireList> {
        let path = "/client/inquire"
        let URLString = CmyAPIClient.webApiPath + path
        let parameters: [String:Any]? = nil
        
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "page": page ?? Int.max,
            "limit": limit ?? Int.max
            ])
        
        let requestBuilder: RequestBuilder<InquireList>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
}
