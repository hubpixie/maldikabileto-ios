//
//  CmyEditPasswordViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/23.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditPasswordViewController: CmyViewController {

    @IBOutlet weak var emailPwdTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTwoTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdThreeTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    private var nextStatA: Bool = false //emailPwdTextField
    private var nextStatB: Bool = false //emailPwdTwoTextField
    private var nextStatC: Bool = false //emailPwdThreeTextField

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //各パスワードを設定する
        self.emailPwdTextField.setBottomBorder()
        self.emailPwdTextField.delegate = self
        self.emailPwdTwoTextField.setBottomBorder()
        self.emailPwdTwoTextField.delegate = self
        self.emailPwdThreeTextField.setBottomBorder()
        self.emailPwdThreeTextField.delegate = self

        //hide password
        self.emailPwdTextField.togglePasswordVisibility()
        self.emailPwdTwoTextField.togglePasswordVisibility()
        self.emailPwdThreeTextField.togglePasswordVisibility()

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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditPassword.navigationbar.top.title", commenmt: "パスワード変更")
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
    
    /*
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.validateInputData()
    }
    */
    
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //パスワードのチェック
        guard let pwd = self.emailPwdTextField.text, pwd.count >= 6 else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditPassword.emailPwdTextField.check.1", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdTextField.becomeFirstResponder()
            })
            return false
        }
        //パスワードのチェック
        guard let pwd2 = self.emailPwdTwoTextField.text, pwd2.count >= 6 else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditPassword.emailPwdTwoTextField.check.1", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdTwoTextField.becomeFirstResponder()
            })
            return false
        }
        
        //現在のものは新しいものと同じ場合
        if pwd == pwd2 {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditPassword.emailPwdTwoTextField.check.2", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdTwoTextField.becomeFirstResponder()
            })
            return false
        }
        ///パスワード（確認用）のチェック
        guard let pwd3 = self.emailPwdThreeTextField.text, pwd3.count >= 6 && pwd2 == pwd3  else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditPassword.emailPwdThreeTextField.check.1", commenmt: "パスワード（確認）はパスワードと不一致です。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdThreeTextField.becomeFirstResponder()
            })
            return false
        }
        
        return true
    }

    // 設定ボタン押下時の処理
    //
    @IBAction func okButtonDidTap(_ sender: UIButton) {
        //画面入力チェックに通らない場合、以降の処理を行わない
        if !self.validateInputData() {return}
        
        //MaldikaBiletoユーザへの更新
        /*
        let update_cmy_user = {(email: String, password: String) in
            Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: {[weak self] (idToken, error) in
                if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                self?.myIndicator.startAnimatingEx(sender: sender)

                //MaldikaBiletoにアカウント情報（emailアドレス）を変更
                let updUser: UserForUpdate = UserForUpdate(phoneNumber: CmyAPIClient.MaldikaBiletoUser?.phoneNumber, nickname: nil, birthday: nil, gender: nil, email: nil, password: password, fcmToken: Messaging.messaging().fcmToken)
                
                CmyUserAPI.updateUser(
                    body: updUser,
                    completion: { (_, error2) in
                        if let err2 = CmyAPIClient.errorInfo(error: error2) {
                            self?.myIndicator.stopAnimatingEx(sender: sender)
                            CmyMsgViewController.showError(sender: self, error:err2, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                            return
                        }
                        
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error3) in
                            self?.myIndicator.stopAnimatingEx(sender: sender)
                            if let err3 = error2 {
                                CmyMsgViewController.showError(sender: self, error:err3, extra: nil)
                                return
                            }
                            self?.dbUpdated = true
                            self?.navigationController?.popViewController(animated: true)
                        })
                })
            })
        }
 */
        let update_cmy_user = {(email: String, password: String) in
            self.myIndicator.startAnimatingEx(sender: sender)
            
            Auth.auth().currentUser?.updatePassword(to: password, completion: {[weak self] (error) in
                if let err = error {
                    CmyMsgViewController.showError(sender: self, error:err, extra: nil)
                    return
                }
                Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error2) in
                    self?.myIndicator.stopAnimatingEx(sender: sender)
                    if let err2 = error2 {
                        CmyMsgViewController.showError(sender: self, error:err2, extra: nil)
                        return
                    }
                    self?.dbUpdated = true
                    self?.navigationController?.popViewController(animated: true)
                })
            })
        }

        //現在のパスワードを使ってサインインする
        Auth.auth().signIn(withEmail: (Auth.auth().currentUser?.email)!, password: (self.emailPwdTextField.text)!) { (_, error) in
            if let error = error {
                CmyMsgViewController.showError(sender: self, error:error, extra: nil)
                return
            }
            
            update_cmy_user((Auth.auth().currentUser?.email)!, (self.emailPwdTwoTextField.text)!)

        }
    }
    
}

extension CmyEditPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailPwdTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdTwoTextField {
            nextStatB = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdThreeTextField {
            nextStatC = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailPwdTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdTwoTextField {
            nextStatB = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdThreeTextField {
            nextStatC = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
