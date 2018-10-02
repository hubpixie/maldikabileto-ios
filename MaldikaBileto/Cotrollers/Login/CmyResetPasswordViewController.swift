//
//  CmyResetPasswordViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/09/11.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyResetPasswordViewController: CmyViewController {

    @IBOutlet weak var emailTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var _successful: Bool = false
    
    private var nextStatA: Bool = true //emailTextField
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        self.emailTextField.setBottomBorder()
        self.emailTextField.delegate = self
        
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "ResetPassword.navigationbar.top.title", commenmt: "パスワードリセット")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // タイトル設定
        self.sourceViewController?.resetNavigationItemTitle()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismissHandler?(self._successful)
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
        
        return true
    }
    
    // 設定ボタン押下時の処理
    //
    @IBAction func okButtonDidTap(_ sender: UIButton) {
        //画面入力チェックに通らない場合、以降の処理を行わない
        if !self.validateInputData() {return}
        
        // パスワードリセットメールを
        // 送信する

        self.myIndicator.startAnimatingEx(sender: sender)
        
        Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!) { [weak self](error) in
            guard let weakSelf = self else {return}
            if let err = error {
                weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                CmyMsgViewController.showError(sender: self, error:err, extra: nil)
                return
            } else {
                //メール送信成功した場合
                let destVC: CmyPasswordResetAlertController = CmyPasswordResetAlertController()
                destVC.okAction = {
                    weakSelf._successful = true
                    weakSelf.navigationController?.popViewController(animated: true)
                }
                weakSelf.present(destVC, animated: true) {
                    weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                }
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate -
//
extension CmyResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.okButton.isEnabled = self.nextStatA ? true: false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.okButton.isEnabled = nextStatA ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

