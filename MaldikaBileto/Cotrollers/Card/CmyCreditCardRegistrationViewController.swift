//
//  CmyCreditCardRegistrationViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit
import PromiseKit

class CmyCreditCardRegistrationViewController: CmyViewController {

    @IBOutlet weak var cardIDTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var cardExPirationDateTextField: CmyTextFieldYearMonthPicker!
    @IBOutlet weak var securityCodeTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var defaultCardCheckButton: CheckButton!
    @IBOutlet weak var registerButton: RoundRectButton!
    @IBOutlet weak var defaultCardLabel: UILabel!
    
    private var nextStatA: Bool = false
    private var nextStatB: Bool = false
    private var nextStatC: Bool = false

    private var _newCard: Card?
    var dismissHandler: ((_ czrd: Card?)->())!
    var dismissHandler__: Promise<Card?>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.navigationbar.top.title", commenmt: "新しいクレジットカードを登録")
        
        //カード番号入力用テキストフィルドの設定
        self.cardIDTextField.setBottomBorder()
        self.cardIDTextField.delegate = self

        //有効期間入力用テキストフィルドの設定
        self.cardExPirationDateTextField.setupDatePicker(parentView: self.view, fromYear: YearMonthPickerView.thisYear)
        self.cardExPirationDateTextField.setBottomBorder()
        self.cardExPirationDateTextField.pickerDelegate = self

        //セキュリティコード入力用テキストフィルドの設定
        self.securityCodeTextField.setBottomBorder()
         self.securityCodeTextField.delegate = self
        
        //標準カードチェックボタン
        self.defaultCardLabel.textColor = UIColor.cmyMainColor()
        self.defaultCardLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.defaultCardCheckButton.label", commenmt: "標準カードに設定")
        self.defaultCardCheckButton.delegate = self

        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        //戻る際のフラグをリセットする
        if !self.seguePrepared {
            self.sourceViewController?.seguePrepared = false
        }
        // ナビゲーションバーを非表示する
        if self.sourceViewController != nil &&
            self.sourceViewController! is CmyCreditCardListViewController {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let handler = self.dismissHandler {
            handler(self._newCard)
        }

        super.viewDidDisappear(animated)
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view == self.view
            || touch.view is UIButton
            || touch.view is RoundRectButton
        {
            self.view.endEditing(true)
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
    
    // 画面入力チェック
    //
    func validateInputData() -> Bool {
        var msgStr: String = ""
        
        // カード番号の桁数チェック
        guard let number = self.cardIDTextField.text, number =~ "[0-9]{\(self.cardIDTextField.minLength),\(self.cardIDTextField.maxLength)}" else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.cardIDTextField.check.1", commenmt: "桁数チェック")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.cardIDTextField.becomeFirstResponder()
            })
            return false
        }
        
        //セキュリティコードの桁数チェック
        guard let code = self.securityCodeTextField.text, code =~ "[0-9]{\(self.securityCodeTextField.minLength),\(self.securityCodeTextField.maxLength)}" else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.securityCodeTextField.check.1", commenmt: "桁数チェック")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.securityCodeTextField.becomeFirstResponder()
            })
            return false
        }

        return true
    }
    

    @IBAction func registerButtonDidTap(_ sender: RoundRectButton) {
        //画面入力チェックに通らない場合、以降の処理を行わない
        if !self.validateInputData() {return}

        //VeritransサーバからMdkTokenを取得する
        let veriCard: VeriCard = VeriCard(
            cardNumber: self.cardIDTextField.text!,
            cardExpire: self.cardExPirationDateTextField.text!,
            securityCode: self.securityCodeTextField.text!)
        
        self.myIndicator.startAnimatingEx(sender: sender)
        CmyAPIClient.prepareHeadersForVeriTrans()
        VeriTransAPI.getCardMdkToken(body: veriCard, completion: {[weak self] (result, error2) in
            self?.myIndicator.stopAnimatingEx(sender: sender)
            guard let weakSelf = self else {return}
            
            if let err2 = CmyAPIClient.errorInfo(error: error2) {
                CmyMsgViewController.showError(sender: weakSelf, error:err2, extra:"[VeriTrans]"/* CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.view.check.1", commenmt: "")*/)
                return
            }
            //取得したMdkTokenを使って、MaldikaBileto APIを経由でVeriTransへカードを登録する
            guard let result = result else {return}
            
            self?.myIndicator.startAnimatingEx(sender: sender)

            Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
                self?.myIndicator.stopAnimatingEx(sender: sender)
                if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                self?.myIndicator.startAnimatingEx(sender: sender)

                let cardAdd = CardForAdd(mdkToken: result.token, defaultCard: weakSelf.defaultCardCheckButton.isChecked ? CardForAdd.DefaultCard.checked : CardForAdd.DefaultCard.unchecked)
                CmyCardAPI.addCard(
                    body: cardAdd,
                    completion: { (card, error3) in
                        self?.myIndicator.stopAnimatingEx(sender: sender)
                        if let err3 = CmyAPIClient.errorInfo(error: error3)  {
                            CmyMsgViewController.showError(sender: weakSelf, error:err3, extra:"[VeriTrans]"/* CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.view.check.1", commenmt: "")*/)
                            return
                        }
                        weakSelf._newCard = card
                        CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: "CreditCardRegistration.registerButton.addCard.ok", commenmt: ""), title: "", okHandler: {(action) in
                                weakSelf.navigationController?.popViewController(animated: true)
                        })
                    })
            })
        })

    }
    
}

extension CmyCreditCardRegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.cardIDTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.registerButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
        if textField == self.securityCodeTextField {
            nextStatC = ((textField.text?.count)! > 0) ? true : false
            self.registerButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = String.replacingInsertingAtRange(range, of: textField.text, with: string)
        
        if textField is CmyTextFieldYearMonthPicker {
            return false
        }
        if textField == self.cardIDTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.registerButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return (str.count <= self.cardIDTextField.maxLength)
        }
        if textField == self.securityCodeTextField {
            nextStatC = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.registerButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return (str.count <= self.securityCodeTextField.maxLength)
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CmyCreditCardRegistrationViewController: CmyTextFieldYearMonthPickerDelegate {
    func yearMonthPicker(yearMonthPicker: CmyTextFieldYearMonthPicker, done: Bool) {
        if done {
            nextStatB = ((yearMonthPicker.text?.count)! > 0 ) ? true : false
            self.registerButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            self.cardExPirationDateTextField.text = yearMonthPicker.yearMonthPicker.date!.toMMYYStringWithSlash()
        }
    }
}


extension CmyCreditCardRegistrationViewController: CheckButtonDelegate {
    func checkButton(checkButton: CheckButton, checked: Bool) {
        if checkButton == self.defaultCardCheckButton {
            //self.defaultCardLabel.isEnabled = checked
        }
    }
}

