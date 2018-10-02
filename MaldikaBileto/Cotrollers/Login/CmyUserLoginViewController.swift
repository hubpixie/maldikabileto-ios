//
//  CmyUserLoginViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/09.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class CmyUserLoginViewController: CmyViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topTitlelabel: UILabel!
    @IBOutlet weak var emailTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var fbLoginButton: RoundRectFlatButton!
    @IBOutlet weak var gidSignInButton: RoundRectFlatButton!
    @IBOutlet weak var nextButton: RoundRectButton!
    
    fileprivate var activeTextField: UITextField!
    //fileprivate var loginProvider: LoginProvider = .email
    
    private var nextStatA: Bool = false
    private var nextStatB: Bool = false
    
    private var _currentAuthUid: String!
    private var _currentFacebookAuthUIds: [String] = []
    private var _currentGoogleAuthUIds: [String] = []
    private var _currentEmailAuthUIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //下記のテキストフィールドのBorderStyleをアンダーバーと設定する
        self.emailTextField.setBottomBorder()
        self.emailPwdTextField.setBottomBorder()
        //hide a password
        self.emailPwdTextField.togglePasswordVisibility()
        // set TextField delegate
        self.emailTextField.delegate = self
        self.emailPwdTextField.delegate = self

        //Facebook Auth
        //3B5998
        self.fbLoginButton.colorsChangedForBorderAndTint = UIColor(displayP3Red: 0x3B/0xFF, green: 0x59/0xFF, blue: 0x98/0xFF, alpha: 1.0)

        // Facebookボタンの高さの制約を取り除く
        for constraint in fbLoginButton.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.constant == 28 {
                fbLoginButton.removeConstraint(constraint)
            }
        }

        //Google Auth
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        // D34836
        self.gidSignInButton.colorsChangedForBorderAndTint = UIColor(displayP3Red: 0xD3/0xFF, green: 0x48/0xFF, blue: 0x36/0xFF, alpha: 1.0)

        // if 4-inch device, make font size smaller for Facebook/google login button
        if UIScreen.main.bounds.width <= 320 {
            var alpha: CGFloat = 0
            if #available(iOS 11, *) { alpha = 2} else {alpha = 3}
            self.fbLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: self.fbLoginButton.titleLabel!.font.pointSize - alpha)
            self.gidSignInButton.titleLabel?.font = UIFont.systemFont(ofSize: self.gidSignInButton.titleLabel!.font.pointSize - alpha)
        }

        // adjust scrollbar topChor if need
        self.scrollView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true

        // Current user Aurh Object
        //CmyViewController.appDelegate?.signOutFirebseAuth()
        self._currentAuthUid = Auth.auth().currentUser?.uid ?? ""
        
        // 後続のチェックに使われる情報を事前に保持しておく。
        if let providers = Auth.auth().currentUser?.providerData {
            for userInfo in providers {
                if let email = userInfo.email, userInfo.providerID == EmailAuthProviderID {
                    self._currentEmailAuthUIds.append(email)
                }
                if userInfo.providerID == FacebookAuthProviderID {
                    self._currentFacebookAuthUIds.append(userInfo.uid)
                }
                if userInfo.providerID == GoogleAuthProviderID {
                    self._currentGoogleAuthUIds.append(userInfo.uid)
                }
            }
        }
        // Current user logout if logining
        CmyViewController.appDelegate?.signOutFirebseAuth()

        //カレントユーザログインプロバイダをemailにセット
        CmyViewController.currentLoginProvider = .email

        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)

        //キーボード制御の初期化
        self.keyboardDelegate = self
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 前画面のタイトルをクリアする
        self.sourceViewController?.clearNavigationItemTitle()
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        // 前画面のタイトルをリセットする
        self.sourceViewController?.resetNavigationItemTitle()
        
        super.viewWillDisappear(animated)
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        //「次へ」ボタンかを判定する
        if let sender_ = sender as? UIButton, sender_ == self.nextButton {
            CmyViewController.currentLoginProvider = .email
        }

        //パスワードリセット画面へ遷移する場合
        if segue.destination is CmyResetPasswordViewController {
            let mySeg: CmyPushFadeSegue = segue as! CmyPushFadeSegue
            mySeg.extraHandler = { [weak self] () in
                guard let weakSelf = self else {return}
                let destVC = segue.destination as! CmyResetPasswordViewController
                destVC.dismissHandler = {(result) in
                }
                destVC.sourceViewController = weakSelf
                weakSelf.clearNavigationItemTitle()
                weakSelf.navigationController?.pushViewController(destVC, animated: true)
            }

        } else {
            //using Mail/password to login firebase
            //
            self.myIndicator.startAnimatingEx(sender: nil)
            
            var credential: AuthCredential!
            if CmyViewController.currentLoginProvider == .email {
                self.nextButton.isEnabled = false
                credential = EmailAuthProvider.credential(withEmail: self.emailTextField.text!, password: self.emailPwdTextField.text!)
            }
            
            // Facebookでログインする場合
            //
            if CmyViewController.currentLoginProvider == .facebook {
                self.fbLoginButton.isEnabled = false
                credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            }
            
            // Facebookでログインする場合
            //
            if CmyViewController.currentLoginProvider == .google {
                self.gidSignInButton.isEnabled = false
                credential = GoogleAuthProvider.credential(
                    withIDToken: GIDSignIn.sharedInstance().currentUser.authentication.idToken,
                    accessToken: GIDSignIn.sharedInstance().currentUser.authentication.accessToken)
            }
            
            
            //指定されたプロバイダーで電話番号と紐づいてログオンさせる
            self.loginToFirebaseAndMoveNextSegue(credential: credential, segue: segue)
        }
     }
    
    func loginToFirebaseAndMoveNextSegue(credential: AuthCredential, segue: UIStoryboardSegue) {
        let disable_button_state = {
            switch CmyViewController.currentLoginProvider {
            case .email:
                self.nextButton.isEnabled = false
            case .facebook:
                self.fbLoginButton.isEnabled = false
            case .google:
                self.gidSignInButton.isEnabled = false
            default:
                break
            }
            self.myIndicator.startAnimatingEx(sender: nil)
        }
        
        let enable_button_state = {
            self.myIndicator.stopAnimatingEx(sender: nil)
            switch CmyViewController.currentLoginProvider {
            case .email:
                self.nextButton.isEnabled = true
            case .facebook:
                self.fbLoginButton.isEnabled = true
            case .google:
                self.gidSignInButton.isEnabled = true
            default:
                break
            }
        }

        //Firebase 認証へ
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self]  (result, error) in
            enable_button_state()
            guard let weakSelf = self else {return}
            if let err = error {
                CmyMsgViewController.showError(sender: self, error:err, extra: nil)
            } else{
                //メールまたは、SNSログインしたユーザの電話番号と、直前の電話番号認証の電話番号が一致しているかチェックを追加
                // 電話番号比較よりもuidが一番楽です
                if let uid = Auth.auth().currentUser?.uid, uid != self?._currentAuthUid {
                    //"UserLogin.view.check.1" = "電話番号認証したアカウントでログインしてください。";
                    CmyMsgViewController.showMsg(sender: weakSelf,
                                                 msg:CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.1", commenmt: "電話番号認証したアカウントでログインしてください"),
                        title: "", okHandler:nil)
                    
                    // 最新のUidをセットする
                    self?._currentAuthUid = Auth.auth().currentUser?.uid ?? ""
                    
                    return
                }

                disable_button_state()
                //MaldikaBileto DBからカレントユーザの情報を取得する
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: {(idToken, error) in
                    enable_button_state()
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    disable_button_state()

                    CmyUserAPI.getUser(completion: { (user, error2) in
                        enable_button_state()
                        if let err2 = CmyAPIClient.errorInfo(error: error2) {
                            CmyMsgViewController.showError(sender: weakSelf, error:err2, extra: nil /*"MaldikaBiletoサーバからユーザ取得に失敗しました。"*/)
                            return
                        }
                        //ユーザが存在する場合
                        CmyAPIClient.MaldikaBiletoUser = user
                        // MaldikaBileto API Client setting when firebase signining
                        CmyAPIClient.setup()

                        if let _ = user {
                            //パスコード入力画面へ
                            //self?.navigationController?.present(mySeg.destination, animated: true)
                            weakSelf.checkPasscodeSetting(){
                                weakSelf.navigationController?.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            //ユーザが存在しない場合、ログアウトさせてから、電話番号入力画面へ遷移する
                            CmyMsgViewController.showMsg(sender: weakSelf,
                                                         msg: CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.2", commenmt: "すでに別ユーザがログインしています"),
                                                         title: "", okHandler:{(action) in
                                    CmyViewController.appDelegate?.signOutFirebseAuth()
                                    _ = weakSelf.moveNextViewController(vcIdentifier: CmyStoryboardIds.phoneNumberRegistration.rawValue)
                                }
                            )
                        }
                    })
                })
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if CmyViewController.currentLoginProvider == .email && identifier != CmySegueIds.resetPasswordSegue.rawValue{
            return self.validateInputData()
        } else {
            return true
        }
    }
    
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //メールアドレスのチェック
        guard let email = self.emailTextField.text, email.count >= 5 && email.contains("@") else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.emailTextField.check.1", commenmt: "メールアドレスを正しく入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
        //パスワードのチェック
        guard let pwd = self.emailPwdTextField.text, pwd.count >= 6 else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.emailPwdTextField.check.1", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
        
        //紐付け済みのメールアドレスかをチェック
        // 紐付けがない場合、ログインしに行かないとします
        if !self._currentEmailAuthUIds.contains(email)
        {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.3", commenmt: "このアカウントはまだ登録していません")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
        return true
    }

    
     @IBAction func facebookAuthButtonDidTap(_ sender: UIButton) {
        //カレント認証プロバイダーを記録する
        CmyViewController.currentLoginProvider = .facebook

        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: ["email"], from: self) { (loginResult, error) in
            if let err = error {
                CmyMsgViewController.showError(sender: self,
                                               error:err,
                                               extra: CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.4", commenmt: "ログインエラー"))
                return
            }
            if let userToken = FBSDKAccessToken.current() {
                //紐付け済みのFacebookアカウントかをチェック
                // 紐付けがない場合、ログインしに行かないとします
                if !self._currentFacebookAuthUIds.contains(userToken.userID) {
                    let msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.3", commenmt: "このアカウントはまだ登録していません")
                    CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
                    return
                }

                self.performSegue(withIdentifier: CmySegueIds.passcodeSettingSegue.rawValue, sender: self)
                
            } else {
                CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.4", commenmt: "ログインエラー"), title: "", okHandler: nil)
            }
        }

     }
    
    @IBAction func googleAuthButtonDidTap(_ sender: UIButton) {
        //カレント認証プロバイダーを記録する
        CmyViewController.currentLoginProvider = .google
        
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
}

extension CmyUserLoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB) ? true: false
        }
        else if textField == self.emailPwdTextField {
            nextStatB = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB) ? true: false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB) ? true: false
            return true
        }
        else if textField == self.emailPwdTextField {
            nextStatB = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB) ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/*
// Facebook Auth Delegate
//
extension CmyUserLoginViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            CmyMsgViewController.showError(sender: self, error:error, extra: nil)
            return
        }
        guard (FBSDKAccessToken.current()) != nil else {
            return
        }
        
        // ...
        self.loginProvider = .facebook
        CmyMsgViewController.showMsg(sender: self,
                                     msg: CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.nextButton.check.ok", commenmt: "アカウント登録が完了しました"),
                                     title:"") {(action) in
            self.performSegue(withIdentifier: CmySegueIds.passcodeSettingSegue.rawValue, sender: self)

        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
}
 */

extension CmyUserLoginViewController: GIDSignInUIDelegate {
}

// Google Auth Delegate
//
extension CmyUserLoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        // ...
        if let error = error {
            CmyMsgViewController.showError(sender: self,
                                           error:error, 
                                           extra: CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.4", commenmt: "ログインエラー"))
            return
        }
        
        guard let _ = user.authentication else { return }
        //紐付け済みのGoogleアカウントかをチェック
        // 紐付けがない場合、ログインしに行かないとします
        if !self._currentGoogleAuthUIds.contains(user.userID){
            let msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserLogin.view.check.3", commenmt: "このアカウントはまだ登録していません")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return
        }

        //        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                       accessToken: authentication.accessToken)
        self.performSegue(withIdentifier: CmySegueIds.passcodeSettingSegue.rawValue, sender: self)

        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

// MARK: CmyKeyboardDelegate

extension CmyUserLoginViewController: CmyKeyboardDelegate {
    func keyboardShow(keyboardFrame: CGRect) {
        if activeTextField == nil {return}
        let heightOfTextField = self.activeTextField.frame.origin.y + self.activeTextField.frame.height + self.scrollView.frame.origin.y + 10
        let heightOfKbd = UIScreen.main.bounds.size.height - keyboardFrame.size.height
        
        if heightOfTextField >= heightOfKbd {
            self.scrollView.contentOffset.y = heightOfTextField - heightOfKbd
        }
    }
    
    func keyboardHide(keyboardFrame: CGRect) {
        self.scrollView.contentOffset.y = 0
    }
}
