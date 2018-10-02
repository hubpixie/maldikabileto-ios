//
//  CmyEditSnsLinkageViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class CmyEditSnsLinkageViewController: CmyViewController {
    @IBOutlet weak var facebookRemarkLabel: UILabel!
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var googleSwitch: UISwitch!

    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //facebook remarkラベル
        // adjust fontsize if 4-inch device
        if self.view.bounds.width <= 320 {
            self.facebookRemarkLabel.font = UIFont.systemFont(ofSize: self.facebookRemarkLabel.font.pointSize - 2)
        }
        // Facebook連携
        self.facebookSwitch.isOn = {() -> Bool in
            if let providers = Auth.auth().currentUser?.providerData
                .filter({ (userInfo: UserInfo) in
                    return userInfo.providerID == FacebookAuthProviderID
                }).map({ (userInfo: UserInfo) in return userInfo.uid}), providers.count > 0
            {
                return true
            } else {
                return false
            }
        }()
        self.toggleSNSlinkState(sender: self.facebookSwitch)
        
        // Facebook連携
        self.googleSwitch.isOn = {() -> Bool in
            if let providers = Auth.auth().currentUser?.providerData
                .filter({ (userInfo: UserInfo) in
                    return userInfo.providerID == GoogleAuthProviderID
                }).map({ (userInfo: UserInfo) in return userInfo.uid}), providers.count > 0
            {
                return true
            } else {
                return false
            }
        }()
        // Googleだけ認証の場合、解除できないようにする
        if self.googleSwitch.isOn && Auth.auth().currentUser?.providerData.count == 1 {
            self.googleSwitch.isEnabled = false
        }
        self.toggleSNSlinkState(sender: self.googleSwitch)

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        //カレントユーザログインプロバイダをnoneにセット
        CmyViewController.currentLoginProvider = .none

        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.navigationbar.top.title", commenmt: "SNS連携")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController is CmyUserInfomationViewController {
            self.sourceViewController?.resetNavigationItemTitle()
            self.sourceViewController?.seguePrepared = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let handle = self.dismissHandler {
            handle(self.dbUpdated)
        }
        super.viewDidDisappear(animated)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // facebook連携変更処理
    //
    @IBAction func facebookSwitchValueChanged(_ sender: UISwitch) {
        self.myIndicator.startAnimatingEx(sender: sender)
        //連携
        if sender.isOn {
            //カレント認証プロバイダーを記録する
            CmyViewController.currentLoginProvider = .facebook
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            loginManager.logIn(withReadPermissions: ["email"], from: self) { (loginResult, error) in
                self.myIndicator.stopAnimatingEx(sender: sender)
                if let err = error {
                    CmyViewController.currentLoginProvider = .none
                    CmyMsgViewController.showError(
                        sender: self,
                        error:err,
                        extra: CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.view.error.1", commenmt: "SNS連携"))
                    return
                }
                if let token = FBSDKAccessToken.current() {
                    self.myIndicator.startAnimatingEx(sender: sender)
                    let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                    self.linkSnsProcess(credential: credential, sender: sender)
                } else {
                    sender.isOn = false
                }
            }

        } else {
            CmyViewController.currentLoginProvider = .none
            //解除
            self.unlinkSnsProcess(fromProvider: FacebookAuthProviderID, sender: sender)
        }
    }
    
    // google連携変更処理
    //
    @IBAction func googleSwitchValueChanged(_ sender: UISwitch) {
        self.myIndicator.startAnimatingEx(sender: sender)
        //連携
        if sender.isOn {
            //カレント認証プロバイダーを記録する
            CmyViewController.currentLoginProvider = .google
            
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().signIn()

        } else {
            //カレント認証プロバイダーを記録する
            CmyViewController.currentLoginProvider = .none
            //解除
            self.unlinkSnsProcess(fromProvider: GoogleAuthProviderID, sender: sender)
        }
    }
    
    // SNS連携
    //
    private func linkSnsProcess(credential: AuthCredential, sender: UISwitch) {
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { [weak self] (_, error) in
            self?.myIndicator.stopAnimatingEx(sender: sender)

            guard let weakSelf = self else {return}
            if let err = error {
                CmyMsgViewController.showError(
                    sender: weakSelf,
                    error:err,
                    extra: CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.view.error.1", commenmt: "SNS連携"))
                sender.isOn = false
                return
            }
            // 画面入力またはDB登録データが変更された事を記録する
            weakSelf.dbUpdated = true
            
            //ログインプロバイダーが一つしかない場合、解除できないようにする
            if sender == weakSelf.facebookSwitch {
                weakSelf.toggleSNSlinkState(sender: weakSelf.googleSwitch)
            } else {
                weakSelf.toggleSNSlinkState(sender: weakSelf.facebookSwitch)
            }
        })
    }
    
    // SNS連携解除
    //
    private func unlinkSnsProcess(fromProvider: String, sender: UISwitch) {
        //解除
        Auth.auth().currentUser?.unlink(fromProvider: fromProvider, completion: { [weak self] (_, error) in
            self?.myIndicator.stopAnimatingEx(sender: sender)
            guard let weakSelf = self else {return}
            if let err = error {
                CmyMsgViewController.showError(
                    sender: weakSelf,
                    error:err,
                    extra: CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.view.error.1", commenmt: "SNS連携"))
                sender.isOn = true
            }
            // 画面入力またはDB登録データが変更された事を記録する
            weakSelf.dbUpdated = true
            
            //ログインプロバイダーが一つしかない場合、解除できないようにする
            if sender == weakSelf.facebookSwitch {
                weakSelf.toggleSNSlinkState(sender: weakSelf.googleSwitch)
            } else {
                weakSelf.toggleSNSlinkState(sender: weakSelf.facebookSwitch)
            }
        })
    }
    
    //SNS連携解除の制御
    //
    private func toggleSNSlinkState(sender: UISwitch) {
        // Facebook/Googleだけ認証の場合、解除できないようにする
        if let firUser = Auth.auth().currentUser, sender.isOn {
            sender.isEnabled = (firUser.providerData.count > 2)
        }
    }
}


// MARK: FGIDSignInUIDelegate
//
extension CmyEditSnsLinkageViewController: GIDSignInUIDelegate {/*
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    */
}


// MARK: GIDSignInDelegate
//
extension CmyEditSnsLinkageViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ...
        self.myIndicator.stopAnimatingEx(sender: self.googleSwitch)

        if let error = error {
            if error._code != -5 {
                CmyMsgViewController.showError(
                    sender: self,
                    error:error,
                    extra: CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.view.error.1", commenmt: "SNS連携"))
            }
            
            self.googleSwitch.isOn = false
            return
        }
        self.myIndicator.startAnimatingEx(sender: self.googleSwitch)
        // Googleと連携
        let credential = GoogleAuthProvider.credential(
            withIDToken: GIDSignIn.sharedInstance().currentUser.authentication.idToken,
            accessToken: GIDSignIn.sharedInstance().currentUser.authentication.accessToken)
        self.linkSnsProcess(credential: credential, sender: self.googleSwitch)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

