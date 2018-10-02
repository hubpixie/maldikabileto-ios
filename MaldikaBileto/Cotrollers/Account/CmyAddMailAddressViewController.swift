//
//  CmyAddMailAddressViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyAddMailAddressViewController: CmyViewController {

    @IBOutlet weak var emailTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailPwdTwoTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    private var nextStatA: Bool = false //emailTextField
    private var nextStatB: Bool = false //emailPwdTextField
    private var nextStatC: Bool = false //emailPwdTwoTextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //メールアドレスを設定する
        self.emailTextField.setBottomBorder()
        self.emailTextField.delegate = self
        //各パスワードを設定する
        self.emailPwdTextField.setBottomBorder()
        self.emailPwdTextField.delegate = self
        self.emailPwdTwoTextField.setBottomBorder()
        self.emailPwdTwoTextField.delegate = self
        
        //hide password
        self.emailPwdTextField.togglePasswordVisibility()
        self.emailPwdTwoTextField.togglePasswordVisibility()
        
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "AddMailAddress.navigationbar.top.title", commenmt: "メールアドレス設定")
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
    
    // 画面入力チェック
    //
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //メールアドレスのチェック
        guard let email = self.emailTextField.text, email.count >= 5 && email.contains("@") else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "AddMailAddress.emailTextField.check.1", commenmt: "メールアドレスを正しく入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailTextField.becomeFirstResponder()
            })
            return false
        }
        //パスワードのチェック
        guard let pwd = self.emailPwdTextField.text, pwd.count >= 6 else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "AddMailAddress.emailPwdTwoTextField.check.1", commenmt: "パスワードを6桁以上入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdTwoTextField.becomeFirstResponder()
            })
            return false
        }
        
        ///パスワード（確認用）のチェック
        guard let pwd2 = self.emailPwdTwoTextField.text, pwd2.count >= 6 && pwd == pwd2  else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "AddMailAddress.emailPwdTwoTextField.check.1", commenmt: "パスワード（確認）はパスワードと不一致です。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailPwdTwoTextField.becomeFirstResponder()
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
        
        // カレントユーザへメールアドレスとパスワードを
        // 紐付けさせる
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: {[weak self] (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            self?.myIndicator.startAnimatingEx(sender: sender)

            //MaldikaBiletoにアカウント情報（emailアドレス）を変更
            let updUser: UserForUpdate = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: (self?.emailTextField.text)!, password: self?.emailPwdTextField.text, fcmToken: Messaging.messaging().fcmToken)
            
            CmyUserAPI.updateUser(
                body: updUser,
                completion: { (_, error2) in
                    if let err2 = CmyAPIClient.errorInfo(error: error2) {
                        self?.myIndicator.stopAnimatingEx(sender: sender)
                        CmyMsgViewController.showError(sender: self, error:err2, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                        return
                    }
                   
                    //再ログインする
                    Auth.auth().signIn(withEmail: (self?.emailTextField.text)!, password: (self?.emailPwdTextField.text)!) { (authResult, error) in
                        self?.myIndicator.stopAnimatingEx(sender: sender)
                        if let err = error {
                            CmyMsgViewController.showError(sender: self, error:err, extra: nil)
                            return
                        }
                        self?.dbUpdated = true
                        self?.navigationController?.popViewController(animated: true)
                    }
            })
        })

    }

    
}

extension CmyAddMailAddressViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdTextField {
            nextStatB = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        else if textField == self.emailPwdTwoTextField {
            nextStatC = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdTextField {
            nextStatB = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        else if textField == self.emailPwdTwoTextField {
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
