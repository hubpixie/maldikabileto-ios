//
//  CmyEditAuthenticationCodeViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/22.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditAuthenticationCodeViewController: CmyViewController {

    @IBOutlet weak var smsCodeInputTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var verificationID: String?
    var dismissHandler: ((_ updated: Bool)->())!
    
    private var dbUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //認証コード入力用テキストフィルドの設定
        self.smsCodeInputTextField.setBottomBorder()
        self.smsCodeInputTextField.frame.size.height = 50
        self.smsCodeInputTextField.delegate = self

        // OKボタン
        self.okButton.isEnabled = ((self.smsCodeInputTextField.text?.count ?? 0) > 0)
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditAuthenticationCode.navigationbar.top.title", commenmt: "電話番号変更")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController is CmyEditPhoneNumberViewController {
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
    
    // 画面入力チェック
    //
    func validateInputData() -> Bool {
        var msgStr: String = ""
        //電話番号の妥当性チェック
        guard let number = self.smsCodeInputTextField.text, number =~ "[0-9]{\(self.smsCodeInputTextField.maxLength),\(self.smsCodeInputTextField.maxLength)}" else {
            msgStr = CmyLocaleUtil.shared.localizedMisc(key: "EditAuthenticationCode.smsCodeInputTextField.check.1", commenmt: "半角数字6桁で入力してください")
            CmyMsgViewController.showMsg(sender: self, msg: msgStr, title: "", okHandler: {(action) in
                self.smsCodeInputTextField.becomeFirstResponder()
            })
            return false
        }
        
        return true
    }

    @IBAction func okButtonDidTap(_ sender: UIButton) {

        //画面入力チェック
        if !self.validateInputData() {return}
        
        //変更処理
        guard let vid = self.verificationID, let vcd = self.smsCodeInputTextField.text else {return}
        self.myIndicator.startAnimatingEx(sender: sender)

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: vid, verificationCode: vcd)
        Auth.auth().useAppLanguage()
        Auth.auth().currentUser?.updatePhoneNumber(
            credential,
            completion: {[weak self] (error) in
            
                self?.myIndicator.stopAnimatingEx(sender: sender)
                guard let weakSelf = self else {return}
                if let error = error {
                    CmyMsgViewController.showError(sender: weakSelf, error:error, extra: CmyLocaleUtil.shared.localizedMisc(key: "EditAuthenticationCode.smsCodeInputTextField.check.2", commenmt: "SM認証コード入力エラー"))
                    return
                }
                self?.myIndicator.startAnimatingEx(sender: sender)

                // 新しい電話番号を登録後、古い電話番号を削除
                // MaldikaBileto ユーザ変更処理を行う
                //user idToken
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: {(idToken, error) in
                    weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    weakSelf.myIndicator.startAnimatingEx(sender: sender)

                    //MaldikaBiletoにアカウント情報を変更
                    let phoneNumber = CmyLocaleUtil.shared.getGeneralPhoneNumber(from: Auth.auth().currentUser?.phoneNumber)
                    let updUser: UserForUpdate = UserForUpdate(phoneNumber: phoneNumber, nickname: nil, birthday: nil, gender: nil, email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)

                    CmyUserAPI.updateUser(
                        body: updUser,
                        completion: { (_, err) in
                            weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                            if let err = CmyAPIClient.errorInfo(error: err) {
                                CmyMsgViewController.showError(sender: self, error:err, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                                return
                            }
                            self?.dbUpdated = true
                            self?.navigationController?.popViewController(animated: true)
                    })
                })
        })
    }
    
}

extension CmyEditAuthenticationCodeViewController: UITextFieldDelegate {
    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 文字数最大を決める.
        let maxLength: Int = self.smsCodeInputTextField.maxLength
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = String.replacingInsertingAtRange(range, of: textField.text, with: string)

        // 文字数がmaxLength以下ならtrueを返す.
        self.okButton.isEnabled = (str.count >= maxLength)
        return (str.count <= maxLength)
    }
    
    /*
     UITextFieldが編集終了する直前に呼ばれる.
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    /*
     改行ボタンが押された際に呼ばれる.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
