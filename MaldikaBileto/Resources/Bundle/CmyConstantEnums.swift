//
//  ConstantEnums.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/08/05.
//  Copyright © 2018 x.yang. All rights reserved.
//

import Foundation

/* 画面のStoryboard Identifier
 SPLASH    Splash
 アプリ説明    Tutorial
 電話番号入力    PhoneNumberRegistration
 SMS認証番号入力    EnterAuthenticationCode
 プロフィール登録    UserProfileRegistration
 メールアドレスorSNS認証    UserRegistration
 パスコード設定    PasscordRegistration
 パスコード設定再入力    PasscordReEnter
 パスコード入力設定選択    StartupPasscordSetting
 パスコード入力    PasscordSetting
 クレジットカード一覧    CreditCardList
 クレジットカード登録    CreditCardRegistration
 クレジットカード詳細    CreditCardDetails
 発行済みチケット一覧    TicketList
 チケット詳細    TickeDetails
 チケット発行    TicketIssue
 チケット発行プレビュー    TicketIssuePreview
 自己使用チケット使用_QR    SelfTicketView
 未使用チケット削除    DeleteTicket
 設定一覧    AppSettings
 会員情報一覧    UserInfomation
 会員情報変更_ニックネーム    EditUserNickname
 会員情報変更_生年月日    EditBirthday
 会員情報変更_メールアドレス（設定）    EditMailAddressAdd
 会員情報変更_メールアドレス（変更）    EditMailAddressSet
 会員情報変更_性別    EditGender
 電話番号入力_変更    EditPhoneNumber
 パスワード入力_変更    EditPassword
 SNS連携_変更    EditPassword
 退会    Withdrawal
 パスコード入力_変更    EditPasscord
 アプリ起動時のパスコード使用有無    PrivacySettings
 お知らせ一覧    InquireList */
enum CmyStoryboardIds: String {
    case tutorial = "Tutorial"
    case tutorialNav = "TutorialNav"
    case phoneNumberRegistration = "PhoneNumberRegistration"
    case enterAuthenticationCode = "EnterAuthenticationCode"
    case userProfileRegistration = "UserProfileRegistration"
    case userRegistration = "UserRegistration"
    case userLogin = "UserLogin"
    case userLoginNav = "UserLoginNav"
    case passcodeSetting = "PasscodeSetting"
    case creditCardList = "CreditCardList"
    case creditCardRegistration = "CreditCardRegistration"
    case creditCardDetails = "CreditCardDetails"
    case ticketList = "TicketList"
    case tickeDetails = "TickeDetails"
    case ticketIssue = "TicketIssue"
    case ticketIssuePreview = "TicketIssuePreview"
    case selfTicketView = "SelfTicketView"
    case deleteTicket = "DeleteTicket"
    case appSettings = "AppSettings"
    case userInfomation = "UserInfomation"
    case editUserNickname = "EditUserNickname"
    case editBirthday = "EditBirthday"
    case editMailAddressAdd = "EditMailAddressAdd"
    case editMailAddressSet = "EditMailAddressSet"
    case editGender = "EeditGender"
    case editPhoneNumber = "EditPhoneNumber"
    case editPassword = "EditPassword"
    case withdrawal = "Withdrawal"
    case privacySettings = "privacySettings"
    case inquireList = "InquireList"
    case webView = "WebView"
    case unusedGiftTicketDetails = "UnusedGiftTicketDetails"
    case unusedPrivateTicketDetails = "UnusedPrivateTicketDetails"
    case usedGiftTicketDetails = "UsedGiftTicketDetails"
    case usedPrivateTicketDetails = "UsedPrivateTicketDetails"
    case erredTicketDetails = "ErredTicketDetails"
}

/* Segue Identifier */
enum CmySegueIds: String {
    case none
    case userProfileRegistrationSegue = "UserProfileRegistrationSegue"
    case creditCardDetailsSegue = "CreditCardDetailsSegue"
    case validateSNSSegue = "ValidateSNSSegue"
    case passcodeSettingSegue = "PasscodeSettingSegue"
    case passcodeLockSegue = "PasscodeLockSegue"
    case editPasscodeSegue = "EditPasscodeSegue"
    case ticketIssuePreviewSegue = "TicketIssuePreviewSegue"
    case unusedGiftTicketDetailsSegue = "UnusedGiftTicketDetailsSegue"
    case unusedPrivateTicketDetailsSegue = "UnusedPrivateTicketDetailsSegue"
    case usedGiftTicketDetailsSegue = "UsedGiftTicketDetailsSegue"
    case usedPrivateTicketDetailsSegue = "UsedPrivateTicketDetailsSegue"
    case erredTicketDetailsSegue = "ErredTicketDetailsSegue"
    case userInfomationSegue = "UserInfomationSegue"
    case creditCardListSegue = "CreditCardListSegue"
    case privacySettingsSegue = "PrivacySettingsSegue"
    case securityMngSegue = "SecurityMngSegue"
    case howtoUseSegue = "HowtoUseSegue"
    case helpSegue = "HelpSegue"
    case serviceItemsSegue = "ServiceItemsSegue"
    case privacyPolicySegue = "PrivacyPolicySegue"
    case licenseSegue = "LicenseSegue"
    case serviceInfoSegue = "ServiceInfoSegue" //dummy
    case editUserNicknameSegue = "EditUserNicknameSegue"
    case editBirthdaySegue = "EditBirthdaySegue"
    case editGenderSegue = "EditGenderSegue"
    case editPhoneNumberSegue = "EditPhoneNumberSegue"
    case editAuthenticationCode = "EditAuthenticationCode"
    case editPasswordSegue = "EditPasswordSegue"
    case addMailAddressSegue = "AddMailAddressSegue"
    case editMailAddressSegue = "EditMailAddressSegue"
    case editSnsLinkageSegue = "EditSnsLinkageSegue"
    case resetPasswordSegue = "ResetPasswordSegue"
    case licenseDetailSegue = "LicenseDetailSegue"
}
