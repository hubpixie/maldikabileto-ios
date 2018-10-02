//
//  CmyViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

@objc protocol CmyKeyboardDelegate {
    @objc optional func keyboardShow(keyboardFrame: CGRect)
    @objc optional func keyboardHide(keyboardFrame: CGRect)
}

class CmyViewController: UIViewController {
    /* 画面起動の状態 */
    enum LoadState {
        case tutorial
        case phoneNumberReg
        case passcode
        case main
        case dummy
    }
    
    /* 画面起動の状態 */
    enum LoginProvider {
        case email
        case facebook
        case google
        case twitter
        case none
    }
    //カレント認証プロバイダー
    static var currentLoginProvider: LoginProvider = .none

    var navigationBarBottomMargin: CGFloat  {
        var bottomMargin : CGFloat = 0
        if #available(iOS 11, *) {
            bottomMargin = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
        }
        return bottomMargin
    }
    var seguePrepared: Bool = false
    // 長時間処理インジケータのインスタンス
    var myIndicator: UIActivityIndicatorView!

    weak var keyboardDelegate: CmyKeyboardDelegate?
    weak var sourceViewController: CmyViewController?
    static var mainViewController: CmyViewController?
    static var inquireViewController: CmyViewController?

    static var appDelegate: AppDelegate?  {
        get {return UIApplication.shared.delegate as? AppDelegate}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Hide the navigation bar on the this view controller
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.keyboardDelegate != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.keyboardWillShow(_:)),
                                                   name: NSNotification.Name.UIKeyboardWillShow,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.keyboardWillHide(_:)) ,
                                                   name: NSNotification.Name.UIKeyboardWillHide,
                                                   object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.keyboardDelegate != nil  {
            NotificationCenter.default.removeObserver(self,
                                                      name: .UIKeyboardWillShow,
                                                      object: self.view.window)
            NotificationCenter.default.removeObserver(self,
                                                      name: .UIKeyboardDidHide,
                                                      object: self.view.window)
        }
    }
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        //self.navigationController?.setNavigationBarHidden(!self.isNavigationBarHidden, animated: false)
    }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //clear navigation title
    //
    func clearNavigationItemTitle() {
        self.navigationItem.title = ""
    }
    
    //reset navigation title
    //
    func resetNavigationItemTitle() {
        self.navigationItem.title = "MaldikaBileto"
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let delegate = self.keyboardDelegate {
            delegate.keyboardShow!(keyboardFrame: keyboardFrame)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let info = notification.userInfo!
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let delegate = self.keyboardDelegate {
            delegate.keyboardHide!(keyboardFrame: keyboardFrame)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //mark: loadCheckForMaldikaBileto
    class func loadCheckForMaldikaBileto(checkHandler: ((_ loadState: LoadState, _ error: Error?)->())?) -> Void{
        //アプリ説明画面の確認
        if !CmyUserDefault.shared.isTutorialShown {
            if let handle = checkHandler {
                handle(.tutorial, nil)
                return
            }
        }
/*
        //dummy
        //<--
        if Auth.auth().currentUser != nil {
            if let handle = checkHandler {
                handle(.dummy, nil)
            }
           return
        }//-->
*/
        
        
        //Firebaseログインユーザ
        guard let firUser = Auth.auth().currentUser, firUser.providerData.count >= 2 else {
            if let handle = checkHandler {
                handle(.phoneNumberReg, nil)
            }
            return
        }
        
        //user idToken
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
            _ = CmyAPIClient.prepareHeaders(sender: nil, idToken: idToken, error:  error)
            //
            
            CmyUserAPI.getUser(completion: {(user, err) in
                if let err = err {
                   if let handle = checkHandler {
                        handle(.phoneNumberReg , err)
                        return
                    }
                }
                
                //Firebaseのカレントユーザと同じであるかをチェック
                CmyAPIClient.MaldikaBiletoUser = user
                // MaldikaBileto API Client setting when firebase signining
                CmyAPIClient.setup()
                
                if user?.phoneNumber ==  CmyLocaleUtil.shared.getGeneralPhoneNumber(from: firUser.phoneNumber!){
                    if let handle = checkHandler {
                        handle(CmyUserDefault.shared.passcodeSetting.passcode.isEmpty
                            || CmyUserDefault.shared.passcodeSetting.isValid  ? .passcode : .main, err)
                        return
                    }
                } else {
                    //カレントユーザからログアウトさせる
                    CmyViewController.appDelegate?.signOutFirebseAuth()
                    if let handle = checkHandler {
                        handle(.phoneNumberReg, nil)
                        return
                    }
                }
            
            })
        })

        return
    }
    
    // MARK: check PasscodeSetting
    // 未設定の場合、パスコード入力画面を開く
    func checkPasscodeSetting(checkedHandler: (()->())?) {
        //パスコード有無のチェック
        if CmyUserDefault.shared.passcodeSetting.passcode.isEmpty {
            let destVC: CmyPasscodeSettingViewController? = PasscodeBundle(window: nil).makeCode() as? CmyPasscodeSettingViewController
            destVC?.isUserDismissEnabled = true
            destVC?.authenticatedCompletion = {(result) in
                //guard let weakSelf = self else {return}
                if result {
                    let pwdLockVC: CmyPasscodeSetLockConfirmController = CmyPasscodeSetLockConfirmController()
                    // OKボタンタップ時のコールバック
                    pwdLockVC.okAction = {
                        //パスコードロック設定を保存
                        var pwdSetting = CmyUserDefault.shared.passcodeSetting
                        pwdSetting.isValid = true
                        CmyUserDefault.shared.passcodeSetting = pwdSetting
                        
                        //パスコードロック設定完了
                        let pwdLockFinVC: CmyPasscodeSetFinAlertController = CmyPasscodeSetFinAlertController()
                        pwdLockFinVC.okAction = {
                            //パスコード設定完了画面を終了し、メイン画面を表示させる
                            destVC?.dismiss(animated: true, completion: checkedHandler)
                        }
                        destVC?.present(pwdLockFinVC, animated: true, completion: nil)
                    }
                    // cancelボタンタップ時のコールバック
                    pwdLockVC.cancelAction = {
                        //パスコード設定完了画面を終了し、メイン画面を表示させる
                        destVC?.dismiss(animated: true, completion: checkedHandler)
                    }
                    destVC?.present(pwdLockVC, animated: true, completion: nil)
                }
            }
            self.present(destVC!, animated: true, completion: nil)
        } else {
            if self is CmyUserProfileRegistrationViewController {return}
            let destVC: CmyPasscodeSettingViewController? = PasscodeBundle(window: nil).authenticate() as? CmyPasscodeSettingViewController
            destVC?.isUserDismissEnabled = true
            destVC?.authenticatedCompletion = {[weak self](result) in
                guard let weakSelf = self else {return}
                if result {
                    //パスコード設定完了画面を終了し、メイン画面を表示させる
                    destVC?.dismiss(animated: true, completion: checkedHandler)
                } else {
                    //規定入力回数までパスコード入力不正の場合、
                    //Firebaseからログアウトさせ、電話番号入力画面へ移動する
                    CmyMsgViewController.showMsg(sender: destVC,
                                                 msg: CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.authenticate.error.2", commenmt: "入力回数上限チェック"),
                                                 title: "", okHandler: {(action) in
                        weakSelf.navigationController?.dismiss(animated: true) {
                            //アプリ関連キャッシュ情報をクリアする
                            CmyUserDefault.shared.cleanUp(userDefaultMode: .tutorialShown)
                            let tutorialVC = UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.tutorialNav.rawValue) as! UINavigationController
                            tutorialVC.viewControllers = [UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.phoneNumberRegistration.rawValue)]

                            CmyViewController.mainViewController?.present(tutorialVC, animated: true) {
                                CmyViewController.mainViewController?.tabBarController?.selectedIndex = 1
                            }
                        }

                    })
                }
            }
            self.present(destVC!, animated: true, completion: nil)
        }
        
    }
    
    // 指定の画面へ遷移する
    //
    func moveNextViewController(vcIdentifier: String) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard.main()
        let vc = storyboard.instantiateViewController(withIdentifier: vcIdentifier)
        self.navigationController?.show(vc, sender: self)
        
        return vc
    }
}
