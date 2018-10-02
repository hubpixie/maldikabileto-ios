//
//  CmyFacebookAuthViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/06/28.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class CmyUserRegistrationViewController: CmyViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topTitlelabel: UILabel!
    @IBOutlet weak var emailTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTwoTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var fbLoginButton: RoundRectFlatButton!
    @IBOutlet weak var gidSignInButton: RoundRectFlatButton!
    @IBOutlet weak var nextButton: RoundRectButton!
    
    fileprivate var activeTextField: UITextField!

    private var nextStatA: Bool = false
    private var nextStatB: Bool = false
    private var nextStatC: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //下記のテキストフィールドのBorderStyleをアンダーバーと設定する
        self.emailTextField.setBottomBorder()
        self.emailTextField.delegate = self
        self.emailPwdTextField.setBottomBorder()
        self.emailPwdTextField.delegate = self
        self.emailPwdTwoTextField.setBottomBorder()
        self.emailPwdTwoTextField.delegate = self
        
        //hide password
        self.emailPwdTextField.togglePasswordVisibility()
        self.emailPwdTwoTextField.togglePasswordVisibility()

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
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //カレントユーザログインプロバイダをemailにセット
        CmyViewController.currentLoginProvider = .email

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

        let mySeg = segue as! CmyPushFadeSegue

        let link_sns = {[weak self](credential) in
            Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (user, error) in
                if CmyViewController.currentLoginProvider == .google {
                    self?.myIndicator.stopAnimatingEx(sender: self?.gidSignInButton)
                } else {
                    self?.myIndicator.stopAnimatingEx(sender: self?.fbLoginButton)
                }
                if let err = error {
                    CmyMsgViewController.showError(sender: self, error:err, extra: nil)
                    return
                }
                if  let _ = user {
                    //ユーザプロフィール登録画面へ
                    let vc = mySeg.destination as! CmyUserProfileRegistrationViewController
                    vc.sourceViewController = self
                    self?.clearNavigationItemTitle()
                    mySeg.source.navigationController?.pushViewController(mySeg.destination, animated: false)
                }
            })

        }
        
        var credential: AuthCredential!
        // メールとパスワードの場合、電話番号と紐づける
        if CmyViewController.currentLoginProvider == .email {
            mySeg.extraHandler = {
                if self.nextStatA && self.nextStatB {
                    self.myIndicator.startAnimatingEx(sender: self.nextButton)
                    
                    credential = EmailAuthProvider.credential(withEmail: self.emailTextField.text!, password: self.emailPwdTextField.text!)
                    Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: {[weak self] (user, error) in
                        self?.myIndicator.stopAnimatingEx(sender: self?.nextButton)
                        if let err = error {
                            CmyMsgViewController.showError(sender: self, error:err, extra: nil)
                            return
                        }
                        self?.myIndicator.startAnimatingEx(sender: self?.nextButton)
                        if let user2 = Auth.auth().currentUser, !user2.isEmailVerified {
                            user2.sendEmailVerification(completion: { (error) in
                                self?.myIndicator.stopAnimatingEx(sender: self?.nextButton)
                                if let err = error {
                                    CmyMsgViewController.showError(sender: self, error:err, extra:nil)
                                } else {
                                    //認証メールアラートを表示後、次画面へ遷移させる
                                    CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.nextButton.sendMail.message" ,commenmt: "メール未認証"), title: "認証メール") {(action) in
                                        let destVC = mySeg.destination as! CmyUserProfileRegistrationViewController
                                        destVC.email = self?.emailTextField.text
                                        self?.clearNavigationItemTitle()
                                        mySeg.source.navigationController?.pushViewController(mySeg.destination, animated: false)

                                    }
                                }
                            })
                        }
                        
                    })
                }
            }
            return
        }
        
        // Facebookでログインする場合、電話番号と紐づける
        //
        if CmyViewController.currentLoginProvider == .facebook {
            mySeg.extraHandler = {
                credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                link_sns(credential)
            }
            return
        }
        
        // Facebookでログインする場合、電話番号と紐づける
        //
        if CmyViewController.currentLoginProvider == .google {
            mySeg.extraHandler = {
                credential = GoogleAuthProvider.credential(
                    withIDToken: GIDSignIn.sharedInstance().currentUser.authentication.idToken,
                    accessToken: GIDSignIn.sharedInstance().currentUser.authentication.accessToken)
                link_sns(credential)
            }
            return
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if CmyViewController.currentLoginProvider == .none {
            return self.validateInputData()
        } else {
            return true
        }
    }
    
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //メールアドレスのチェック
        guard let email = self.emailTextField.text, email.count >= 5 && email.contains("@") else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.emailTextField.check.1", commenmt: "メールアドレスを正しく入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
        //パスワードのチェック
        guard let pwd = self.emailPwdTextField.text, pwd.count >= 6 else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.emailPwdTextField.check.1", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
        ///パスワード（確認用）のチェック
        guard let pwd2 = self.emailPwdTwoTextField.text, pwd2.count >= 6 && pwd == pwd2  else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.emailPwdTwoTextField.check.1", commenmt: "パスワード（確認）はパスワードと不一致です。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "")
            return false
        }
 
        return true
    }
    
    
    @IBAction func facebookAuthButtonDidTap(_ sender: UIButton) {
        self.myIndicator.startAnimatingEx(sender: sender)
        //カレント認証プロバイダーを記録する
        CmyViewController.currentLoginProvider = .facebook

        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: ["email"], from: self) { (loginResult, error) in
            self.myIndicator.stopAnimatingEx(sender: sender)
            if let err = error {
                CmyMsgViewController.showError(
                    sender: self,
                    error:err,
                    extra: CmyLocaleUtil.shared.localizedMisc(key: "EditSnsLinkage.view.error.1", commenmt: "SNS連携"))
                return
            }
            if let _ = FBSDKAccessToken.current() {
                self.myIndicator.startAnimatingEx(sender: sender)
                self.performSegue(withIdentifier: CmySegueIds.userProfileRegistrationSegue.rawValue, sender: self)
            }
        }
    }
    
    @IBAction func googleAuthButtonDidTap(_ sender: UIButton) {
        self.myIndicator.startAnimatingEx(sender: sender)
        //カレント認証プロバイダーを記録する
        CmyViewController.currentLoginProvider = .google

        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
}

// MARK: UITextFieldDelegate
//
extension CmyUserRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdTextField {
            nextStatB = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdTwoTextField {
            nextStatC = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdTextField {
            nextStatB = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdTwoTextField {
            nextStatC = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // SNS連携ボタンの枠線を変更する
    //
    func adjustSNSButtonAttributes(color: UIColor, sender: UIButton) {
        
        //layer
        sender.layer.borderWidth = 6 / UIScreen.main.nativeScale
        sender.layer.borderColor = UIColor(displayP3Red: 246/255, green: 193/255, blue: 108/255, alpha: 1.0).cgColor
        sender.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        // subviews layers
        sender.layer.cornerRadius = sender.frame.height / 2
        sender.backgroundColor = UIColor.white
        sender.setTitleColor(color.withAlphaComponent(0.5), for: .disabled)
        sender.setTitleColor(color, for: .normal)
    }
}

/*
// MARK: Facebook Auth Delegate
//

extension CmyUserRegistrationViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let err = error {
            CmyMsgViewController.showError(sender: self, error:err, extra:nil)
            return
        }
        guard (FBSDKAccessToken.current()) != nil else {
            return
        }
        //UserRegistration.nextButton.check.ok
        self.loginProvider = .facebook
        CmyMsgViewController.showMsg(sender: self,
                                     msg: CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.nextButton.check.ok", commenmt: "アカウント登録が完了しました"),
                                     title:"") {(action) in
            self.performSegue(withIdentifier: CmySegueIds.userProfileRegistrationSegue.rawValue, sender: self)
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
 
    
}
*/

// MARK: FGIDSignInUIDelegate
//
extension CmyUserRegistrationViewController: GIDSignInUIDelegate {
}

// MARK: GIDSignInDelegate
//
extension CmyUserRegistrationViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.myIndicator.stopAnimatingEx(sender: self.gidSignInButton)

        // ...
        if let error = error {
            CmyMsgViewController.showError(sender: self,
                                           error:error,
                                           extra: CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.nextButton.check.error.1", commenmt: "Google認証エラー"))
            return
        }
        self.myIndicator.startAnimatingEx(sender: self.gidSignInButton)
        self.performSegue(withIdentifier: CmySegueIds.userProfileRegistrationSegue.rawValue, sender: self)

    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

// MARK: CmyKeyboardDelegate

extension CmyUserRegistrationViewController: CmyKeyboardDelegate {
    func keyboardShow(keyboardFrame: CGRect) {
        if self.activeTextField == nil {return}
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

