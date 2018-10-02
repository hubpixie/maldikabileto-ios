//
//  CmyUserDefault.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/10.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

class CmyUserDefault: UserDefaults {
    enum UserDataMode: Int {
        case tutorialShown
        case all
    }
    static  let shared: CmyUserDefault = CmyUserDefault()
    private let kIdTokenKey: String = "currentUserIdToken" // reserved
    private let kIsTutorialShownKey: String = "isTutorialShown"
    private let kPasscodeSettingKey: String = "passcodeSetting"
    private let kInquireRefListKey: String = "kInquireRefList"
    private let kDefaultCardIdKey: String = "defaultCardId"
    /*************
      Debug
    *************/
    private let kPhoneVerificationID: String = "phoneVerificationID"
    
    /*
    public var currentUserIdToken: String {
        get {
            guard let s = UserDefaults.standard.string(forKey: kIdTokenKey) else {
                return ""
            }
            return s
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: kIdTokenKey)
            UserDefaults.standard.synchronize()
        }
    }*/
    
    public var isTutorialShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kIsTutorialShownKey)
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: kIsTutorialShownKey)
            UserDefaults.standard.synchronize()
        }
    }

    public var passcodeSetting: PasscodeBundle.Setting {
        get {
            let dic = UserDefaults.standard.dictionary(forKey: kPasscodeSettingKey)
            return PasscodeBundle.Setting.setting(from: dic)
        }
        set (newValue) {
            UserDefaults.standard.set(newValue.dictionary(), forKey: kPasscodeSettingKey)
            UserDefaults.standard.synchronize()
        }
    }

    public var defaultCardId: String? {
        get {
            return UserDefaults.standard.string(forKey: kDefaultCardIdKey)
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: kDefaultCardIdKey)
            UserDefaults.standard.synchronize()
        }
    }

    public var inquireRefList: [CmyUserBundle.InquireRef] {
        get {
            var inqList: [CmyUserBundle.InquireRef] = []
            if let list = UserDefaults.standard.array(forKey: kInquireRefListKey) {
                for item in list {
                    if let dic = item as? Dictionary<String, Any> {
                        let inq = CmyUserBundle.InquireRef.inquireRef(from: dic)
                        inqList.append(inq)
                    }
                }
            }
            return inqList
        }
        set (newValue) {
            var list: [Dictionary<String, Any>] = []
            for inq in newValue {
                list.append(inq.dictionary())
            }
            UserDefaults.standard.set(list, forKey: kInquireRefListKey)
            UserDefaults.standard.synchronize()
        }
    }
    

    //mark: Debug
    public var phoneVerificationID: String {
        get {
            guard let s = UserDefaults.standard.string(forKey: kPhoneVerificationID) else {
                return ""
            }
            return s
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: kPhoneVerificationID)
            UserDefaults.standard.synchronize()
        }
    }

    //  アプリ保存情報を削除する
    //
    public func cleanUp(userDefaultMode: UserDataMode) {
        if userDefaultMode == UserDataMode.all {
            UserDefaults.standard.removeObject(forKey: kIsTutorialShownKey)
            UserDefaults.standard.removeObject(forKey: kPasscodeSettingKey)
            UserDefaults.standard.removeObject(forKey: kDefaultCardIdKey)
            UserDefaults.standard.removeObject(forKey: kInquireRefListKey)
        } else if userDefaultMode == UserDataMode.tutorialShown {
            //ログアウト時、アプリ説明保存情報とお知らせ情報を消さないとする
            UserDefaults.standard.removeObject(forKey: kPasscodeSettingKey)
            UserDefaults.standard.removeObject(forKey: kDefaultCardIdKey)
        }
        UserDefaults.standard.synchronize()
    }
    
}
