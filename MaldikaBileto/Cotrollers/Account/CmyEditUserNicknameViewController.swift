//
//  CmyEditUserNicknameViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/21.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditUserNicknameViewController: CmyViewController {

    @IBOutlet weak var nicknameTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //ニックネームを設定する
        self.nicknameTextField.text = CmyAPIClient.MaldikaBiletoUser?.nickname
        self.nicknameTextField.setBottomBorder()
        self.nicknameTextField.delegate = self
        
        // OKボタン
        self.okButton.isEnabled = ((self.nicknameTextField.text?.count ?? 0) > 0)
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditUserNickname.navigationbar.top.title", commenmt: "ニックネーム変更")
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
    
    //画面入力チェック
    //
    private func validateInputDara() -> Bool {
        //ニックネームの範囲チェック
        
        if !(1...self.nicknameTextField.maxLength).contains(self.nicknameTextField.text?.count ?? 0) {
            CmyMsgViewController.showMsg(sender: self,
                                          msg: CmyLocaleUtil.shared.localizedMisc(key: "EditUserNickname.nicknameTextField.check.message", commenmt: "ニックネーム範囲チェック"),
                                          title: "入力エラー")
            return false
        }
        return true
    }

    
    @IBAction func okButtonDidTap(_ sender: UIButton) {
        //画面入力チェックを実施
        if !self.validateInputDara() {return}
        
        //user idToken
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
           
            self?.myIndicator.startAnimatingEx(sender: sender)
            //MaldikaBiletoにアカウント情報を変更
            let updUser: UserForUpdate = UserForUpdate(phoneNumber: nil, nickname: self?.nicknameTextField.text, birthday: nil, gender: nil, email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)
            
            CmyUserAPI.updateUser(
                body: updUser,
                completion: { (_, err) in
                    self?.myIndicator.stopAnimatingEx(sender: sender)
                    if let err = CmyAPIClient.errorInfo(error: err) {
                        CmyMsgViewController.showError(sender: self, error:err, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                        return
                    }
                    self?.dbUpdated = true
                    self?.navigationController?.popViewController(animated: true)
            })
        })
        
    }
    
}

extension CmyEditUserNicknameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.nicknameTextField {
            self.okButton.isEnabled = (textField.text?.count ?? 0 > 0) ? true: false
        }
    }

    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 文字数最大を決める.
        //let maxLength: Int = self.nicknameTextField.maxLength
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = String.replacingInsertingAtRange(range, of: textField.text, with: string)

        // 文字数がmaxLength以下ならtrueを返す.
        self.okButton.isEnabled = (str.count > 0)
        return true
    }
    
    /*
     UITextFieldが編集終了する直前に呼ばれる.
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.nicknameTextField {
            let cnt = textField.text?.count ?? 0
            self.okButton.isEnabled = (cnt > 0) ? true: false
        }
        return true
    }
    
    /*
     改行ボタンが押された際に呼ばれる.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
