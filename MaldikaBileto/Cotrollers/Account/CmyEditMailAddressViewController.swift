//
//  CmyEditMailAddressViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditMailAddressViewController: CmyViewController {

    @IBOutlet weak var emailTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var emailTwoTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    private var nextStatA: Bool = true //emailTextField
    private var nextStatB: Bool = false //emailTwoTextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //メールアドレスを設定する
        self.emailTextField.isUserInteractionEnabled = false
        self.emailTextField.text = CmyAPIClient.MaldikaBiletoUser?.email
        self.emailTextField.setBottomBorder()
        //self.emailTextField.delegate = self
        self.emailTwoTextField.setBottomBorder()
        self.emailTwoTextField.delegate = self

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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditMailAddress.navigationbar.top.title", commenmt: "メールアドレス設定")
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
        //現在メールアドレスのチェック
        guard let email = self.emailTextField.text, email.count >= 5 && email.contains("@") else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditMailAddress.emailTextField.check.1", commenmt: "メールアドレスを正しく入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailTextField.becomeFirstResponder()
            })
            return false
        }

        //新しいメールアドレスのチェック
        guard let email2 = self.emailTwoTextField.text, email2.count >= 5 && email2.contains("@") else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditMailAddress.emailTextField.check.1", commenmt: "メールアドレスを正しく入力してください。")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.emailTwoTextField.becomeFirstResponder()
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
            let updUser: UserForUpdate = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: (self?.emailTwoTextField.text)!, password: nil, fcmToken: Messaging.messaging().fcmToken)
            
            CmyUserAPI.updateUser(
                body: updUser,
                completion: { (_, error2) in
                    self?.myIndicator.stopAnimatingEx(sender: sender)
                    if let err2 = CmyAPIClient.errorInfo(error: error2) {
                        CmyMsgViewController.showError(sender: self, error:err2, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                        return
                    }
                    
                    self?.dbUpdated = true
                    self?.navigationController?.popViewController(animated: true)
            })
        })

    }
    
}

// MARK: - UITextFieldDelegate -
//
extension CmyEditMailAddressViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB ) ? true: false
        }
        else if textField == self.emailTwoTextField {
            nextStatB = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB) ? true: false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
//            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
//            self.okButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return false
        }
        else if textField == self.emailTwoTextField {
            nextStatB = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = (nextStatA && nextStatB) ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
