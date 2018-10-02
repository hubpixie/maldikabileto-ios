//
//  ViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/06/27.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import FirebaseAuth

class CmyPhoneNumberRegistrationViewController: CmyViewController {

    @IBOutlet weak var phoneNumberTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var nextButton: RoundRectButton!
    
    override func viewDidLoad() {
        //self.isNavigationBarHidden = true
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //下記のテキストフィールドのBorderStyleをアンダーバーと設定する
        self.phoneNumberTextField.setBottomBorder()
        self.phoneNumberTextField.frame.size.height = 40

        self.phoneNumberTextField.delegate = self
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)

        //次へボタン
        self.nextButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view == self.view
        {
            self.phoneNumberTextField.endEditing(true)
        }
    }

    /// 画面遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mySeg = segue as! CmyPushFadeSegue
        guard let phoneNumStr = self.phoneNumberTextField.text, phoneNumStr.count > 0  else {
            return
        }
        
        self.myIndicator.startAnimatingEx(sender: sender)
        
        mySeg.extraHandler = { [weak self]() in
            guard let weakSelf = self else {return}
            
             //TODO
            let phoneNumber = CmyLocaleUtil.shared.getGlobalPhoneNumber(from: weakSelf.phoneNumberTextField.text)
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                
                self?.myIndicator.stopAnimatingEx(sender: sender)
                
                if let error = error {
                    CmyMsgViewController.showError(sender: weakSelf, error:error, extra: "")
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                // move the next screen
                
                //TODO else
                if let vc: CmyEnterAuthenticationCodeViewController = mySeg.destination as? CmyEnterAuthenticationCodeViewController {
                    weakSelf.clearNavigationItemTitle()
                    vc.verificationID = verificationID
                    mySeg.source.navigationController?.pushViewController(mySeg.destination, animated: false)
                }
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        self.phoneNumberTextField.resignFirstResponder()
        return validateInputData()
    }
    
    // 画面入力チェック
    //
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //電話番号の妥当性チェック
        guard let number = self.phoneNumberTextField.text, number =~ "[0-9]{\(self.phoneNumberTextField.maxLength),\(self.phoneNumberTextField.maxLength)}" else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "PhoneNumberRegistration.phoneNumberTextField.check.1", commenmt: "数字以外が入力されている")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.phoneNumberTextField.becomeFirstResponder()
            })
            return false
        }
        
        return true
    }
    

}


extension CmyPhoneNumberRegistrationViewController: UITextFieldDelegate {
    
    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 文字数最大を決める.
        let maxLength: Int = self.phoneNumberTextField.maxLength
        let minLength: Int = self.phoneNumberTextField.minLength

        // 入力済みの文字と入力された文字を合わせて取得.
        let str = String.replacingInsertingAtRange(range, of: textField.text, with: string)
        
        // 文字数がmaxLength以下ならtrueを返す.
        self.nextButton.isEnabled = (str.count >= minLength)
        return (str.count <= maxLength)
    }
    
    /*
     UITextFieldが編集終了する直前に呼ばれる
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

