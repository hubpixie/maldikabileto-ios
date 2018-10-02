//
//  CmyEditPhoneNumberViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/22.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditPhoneNumberViewController: CmyViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var nextButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //下記のテキストフィールドのBorderStyleをアンダーバーと設定する
        self.phoneNumberTextField.setBottomBorder()
        self.phoneNumberTextField.frame.size.height = 40
        self.phoneNumberTextField.text = CmyAPIClient.MaldikaBiletoUser?.phoneNumber
        self.phoneNumberTextField.delegate = self
        
        //電話番号ラベル
        // adjust fontsize if 4-inch device
        if self.view.bounds.width <= 320 {
            self.phoneNumberLabel.font = UIFont.systemFont(ofSize: self.phoneNumberLabel.font.pointSize - 1)
        }
        
        //次へボタン
        self.nextButton.isEnabled = ((self.phoneNumberTextField.text?.count ?? 0) > 0)

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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditPhoneNumber.navigationbar.top.title", commenmt: "電話番号変更")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !self.seguePrepared {
            if self.sourceViewController is CmyUserInfomationViewController {
                self.sourceViewController?.resetNavigationItemTitle()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let handle = self.dismissHandler {
            handle(self.dbUpdated)
        }
        super.viewDidDisappear(animated)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        self.phoneNumberTextField.resignFirstResponder()
        return self.validateInputData()
    }
    
    /// 画面遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mySeg = segue as! CmyPushFadeSegue
        guard let phoneNumStr = self.phoneNumberTextField.text, phoneNumStr.count > 0  else {
            return
        }
        self.phoneNumberTextField.resignFirstResponder()
        
        mySeg.extraHandler = { [weak self]() in
            guard let weakSelf = self else {return}
            self?.seguePrepared = true
            
            // 電話番号検証
            self?.myIndicator.startAnimatingEx(sender: sender)
            let phoneNumber = CmyLocaleUtil.shared.getGlobalPhoneNumber(from: weakSelf.phoneNumberTextField.text)
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                self?.myIndicator.stopAnimatingEx(sender: sender)
                if let error = error {
                    self?.seguePrepared = false
                    CmyMsgViewController.showError(sender: weakSelf, error:error, extra: "")
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                // move the next screen
                
                //TODO else
                if let vc: CmyEditAuthenticationCodeViewController = mySeg.destination as? CmyEditAuthenticationCodeViewController {
                    weakSelf.clearNavigationItemTitle()
                    vc.sourceViewController = weakSelf
                    vc.verificationID = verificationID
                    vc.dismissHandler = {(updated) in
                        weakSelf.dbUpdated = updated
                        if updated {
                            weakSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                    mySeg.source.navigationController?.pushViewController(mySeg.destination, animated: false)
                }
            }
        }
        super.prepare(for: segue, sender: sender)
    }    

    // 画面入力チェック
    //
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //電話番号の妥当性チェック
        guard let number = self.phoneNumberTextField.text, number =~ "[0-9]{\(self.phoneNumberTextField.maxLength),\(self.phoneNumberTextField.maxLength)}" else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditPhoneNumber.phoneNumberTextField.check.1", commenmt: "電話番号は10桁または11桁の数字で入力してください")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.phoneNumberTextField.becomeFirstResponder()
            })
            return false
        }
        
        return true
    }

}

extension CmyEditPhoneNumberViewController: UITextFieldDelegate {
    
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
