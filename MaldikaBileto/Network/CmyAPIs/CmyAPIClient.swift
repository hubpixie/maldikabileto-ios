//
//  CmyAPIClient.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

import Alamofire
import SwaggerClient


class CmyAPIClient: SwaggerClientAPI {
    enum HttpStatusCode: Int {
        //不正なアクセス
        case invalidAccess = 400
        //データなし
        case notFound = 404
        //権限なし
        case notPermited = 406
        //データ重複
        case duplicatedData = 409
        //未使用チケットあり
        case unusedTickets = 412
        //データ不正
        case dirtyData = 422
        //内部エラー
        case internalError = 500
        //FIRBASEネットワックエラー
        case firebaseNetworkError = 17020
        //その他
        case ohter
    }
    
    #if STAGING
    static var webApiPath = "http://18.179.170.0:58443/api"
    static var veriTransApiPath = "https://api.veritrans.co.jp" //トークン取得
    static var veriTransApiKey = "cd76ca65-7f54-4dec-8ba3-11c12e36a548" //トークン取得
    #else
    static var webApiPath = "http://18.179.170.0:58443/api"
    static var veriTransApiPath = "https://api.veritrans.co.jp" //トークン取得
    static var veriTransApiKey = "cd76ca65-7f54-4dec-8ba3-11c12e36a548" //トークン取得
    #endif
    
    // コモーユーザオブジェクト
    static var MaldikaBiletoUser: User?
    // お知らせ一覧オブジェクト
    //static var currentInquireList: InquireList?

    // FCMトークン取得通知制御フラグ
    private static var _fcmTokenNoticed: Bool = false
    
    //private static var _inquiringTimer: Timer?

    // get idToken by Synchronous call
    //
    class func getIDTokenSync<Bool,String,Error>(refreshed: Bool, async: (Bool, @escaping ((String,Error)->Void))->Void) -> (String?, Error?) {
        var result: (String?, Error?)? = nil
        
        let group = DispatchGroup()
        group.enter()
        
        async(refreshed) {
            (id, error) in
            result = (id, error)
            group.leave()
        }
        group.wait()
        
        return result!
    }
    
    // Verify network connection
    //
    class func verifyConnect(host: String) -> Bool {
        return NetworkReachabilityManager(host: host)?.isReachable ?? false
    }
    
    // set idToken to customeHeaders
    //
    class func prepareHeaders(sender: UIViewController?, idToken: String?, error: Error?) -> Bool {
        var retStat: Bool = false
        let errCode = NSURLErrorNotConnectedToInternet
        
        //check network connection
        if !verifyConnect(host: webApiPath) {
            CmyMsgViewController.showError(sender: sender, error:(errCode, nil, NSError(domain: "MaldikaBileto", code: errCode, userInfo: nil)), extra: nil)
            return false
        }
        if let error = error {
            if error._code == CmyAPIClient.HttpStatusCode.firebaseNetworkError.rawValue {
                CmyMsgViewController.showError(sender: sender, error:(errCode, nil, NSError(domain: "MaldikaBileto", code: errCode, userInfo: nil)), extra: nil)
            } else {
                CmyMsgViewController.showError(sender: sender, error:error, extra: nil)
            }
            return false
        }
        
        //リクエストヘッダをセット
        customHeaders["Accept"] = "application/json"
        customHeaders["Content-Type"] = "application/json"

        if let token = idToken {
            retStat = true
            customHeaders["Authorization"] = "Bearer \(token)"
            
        }else {
            let result = getIDTokenSync(refreshed: false, async: (Auth.auth().currentUser?.getIDTokenForcingRefresh)!)
            if let idToken = result.0 {
                retStat = true
                customHeaders["Authorization"] = "Bearer \(idToken!)"
            }
        }
        
        return retStat
    }

    class func prepareHeadersForVeriTrans() {
        customHeaders.removeAll()
        customHeaders["Accept"] = "application/json"
        customHeaders["Content-Type"] = "application/json; charset=utf-8"
    }
    
    class func getHeadErrorDesc() -> String? {
        if customHeaders.keys.contains("Error") {
            return customHeaders["Error"]
        }else{
            return nil
        }
    }
    
    class func errorInfo(error: Error?) ->(Int, Data?, Error)? {
        if error != nil && error is ErrorResponse? {
            let error = error as? ErrorResponse
            if case let ErrorResponse.error(info) = error! {
                return info
            }
        }
        return nil
    }
    
    // setup setting
    //
    class func setup() {
        if !_fcmTokenNoticed {
            //FCMトークン更新
            if let user = MaldikaBiletoUser,
                (user.fcmToken != nil &&  user.fcmToken! != Messaging.messaging().fcmToken)
                || user.fcmToken == nil{
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                    if !CmyAPIClient.prepareHeaders(sender: nil, idToken: idToken, error:  error) {return}

                    //MaldikaBiletoにFcmトークン更新を行う
                    //
                    let updUser = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)
                    CmyUserAPI.updateUser(body: updUser, completion: {_, _ in})
                })
            }

            //通知オブザーバーを登録
            NotificationCenter.default.addObserver(self, selector: #selector(CmyAPIClient.messagingDidReceiveFCMToken(notification:)),
                                                   name: Notification.Name("FCMToken"), object: nil)
            _fcmTokenNoticed = true
        }

        // お知らせ一覧取得のスケジューラを設定する
        //_inquiringTimer = Timer.scheduledTimer(timeInterval: 5 * 60, target: self, selector: #selector(CmyAPIClient.getInquireList), userInfo: nil, repeats: true)
    }
    
    // unsetup setting
    //
    class func unsetup() {
        //通知オブザーバーを解除
        if _fcmTokenNoticed {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("FCMToken"), object: nil)
            _fcmTokenNoticed = false
        }
        
        // タイマー停止
        //_inquiringTimer?.invalidate()
    }
    
    // FCMトークン受け取り通知処理
    //
    @objc class func messagingDidReceiveFCMToken(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        if let fcmToken = userInfo["token"] as? String {
//            Messaging.messaging().shouldEstablishDirectChannel = true

            //self.fcmTokenMessage.text = "Received FCM token: \(fcmToken)"
            // save fcmToken to MaldikaBileto db
            //user idToken
            Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if !CmyAPIClient.prepareHeaders(sender: nil, idToken: idToken, error:  error) {return}

                //MaldikaBiletoにFcmトークン更新を行う
                //
                let updUser = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: nil, password: nil, fcmToken: fcmToken)
                CmyUserAPI.updateUser(body: updUser, completion: {_, _ in})
            })
        }
    }
    
    //お知らせ一覧取得
    class func fetchInquireList(completionHander: ((_ inquireList: InquireList?)->())?) {
        let vc = CmyViewController.inquireViewController

        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
            
            if !CmyAPIClient.prepareHeaders(sender: vc, idToken: idToken, error:  error) {
                completionHander?(nil)
                return
            }

            CmyInquireAPI.getInquireList(page: nil, limit: nil, completion: {(result, error2) in
                if let err2 = CmyAPIClient.errorInfo(error: error2), err2.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                    CmyMsgViewController.showError(sender: vc, error:err2, extra: nil)
                    completionHander?(nil)
                    return
                }
                
                //バッジ表示の初期化
                CmyViewController.mainViewController?.tabBarController?.tabBar.items?[0].badgeValue = nil
                
                //データ有無判定
                if let result = result, result.inquires.count > 0 {
                    //前回取得結果の既読状況を確認し、増えた分に対してバッジをつける
                    var difCnt: Int = 0
                    let oldList = CmyUserDefault.shared.inquireRefList
                    if oldList.count > 0 {
                        for item in result.inquires {
                            if !oldList.contains(where: { (obj) -> Bool in
                                if item.inquireId == obj.inquireId && item.createdAt == obj.createdAt && obj.readState {
                                    return true
                                } else {
                                    return false
                                }
                            }) {
                                difCnt += 1
                            } else {
                                continue
                            }
                        }
                    } else {
                        difCnt = result.inquires.count
                    }
                    
                    // バッジ表示の更新
                    // TODO Phase 1で未読件数を出さないとする
                    // お知らせ画面を開かないときのみ、パッジをつけないとする
                    if difCnt > 0 && vc == nil {
                        //CmyViewController.mainViewController?.tabBarController?.tabBar.items?[0].badgeValue = "\(difCnt)"
                        if let tabBarItem = CmyViewController.mainViewController?.tabBarController?.tabBar.items?[0] {
                            tabBarItem.badgeValue = "●"
                            tabBarItem.badgeColor = .clear
                            tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor.rawValue: UIColor.red], for: .normal)
                        }
                        
                    }
                    
                    //call completionHander
                    completionHander?(result)
                } else {
                    completionHander?(nil)
                }
            })
            
        })
    }

}

