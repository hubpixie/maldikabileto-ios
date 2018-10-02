//
//  CmyUserProfileRegistrationViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/05.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyUserProfileRegistrationViewController: CmyViewController {

    @IBOutlet weak var nicknameTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var birthdateTextField: CmyTextFieldDatePicker!
    @IBOutlet weak var genderTextFieldPullDown: CmyTextFieldPullDown!
    @IBOutlet weak var nextButton: RoundRectButton!
    
    var email: String?
    private var phoneNumber: String?
    private var nextStatA: Bool = false
    private var nextStatB: Bool = true //任意
    private var nextStatC: Bool = true //任意

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //
        self.nicknameTextField.setBottomBorder()
        
        // 生年月日
        self.birthdateTextField.setupDatePicker(parentView: self.view)
        self.birthdateTextField.datePicker.maximumDate = Date()
        self.birthdateTextField.setBottomBorder()
        
        // 電話番号
        self.phoneNumber = CmyLocaleUtil.shared.getGeneralPhoneNumber(from: Auth.auth().currentUser?.phoneNumber)

        //性別プルダウン
        self.setupGenderDropDown()
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //入力チェック
        self.nicknameTextField.delegate = self
        self.birthdateTextField.pickerDelegate = self
        self.genderTextFieldPullDown.pickerDelegate = self
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

    func setupGenderDropDown() {
        let listStr = CmyLocaleUtil.shared.localizedMisc(key: "UserProfileRegistration.genderTextField.dropdown.list", commenmt: "性別")
        let list = listStr.components(separatedBy: ",")
        self.genderTextFieldPullDown.list = list
        self.genderTextFieldPullDown.setupPulldown(parentView: self.view)
        self.genderTextFieldPullDown.setBottomBorder()
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != self.genderTextFieldPullDown.pulldown
            || touch.view == self.view
        {
            self.genderTextFieldPullDown.endEditing(true)
            self.genderTextFieldPullDown.pulldown.isHidden = true
        }
    }

    /// 画面遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //user idToken
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { [weak self](idToken, error) in
            guard let weakSelf = self else {return}
            
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            weakSelf.myIndicator.startAnimatingEx(sender: weakSelf.nextButton)

            //MaldikaBiletoにアカウント登録
            let inUsr: UserForAdd =
                UserForAdd(phoneNumber: weakSelf.phoneNumber, nickname: weakSelf.nicknameTextField.text, birthday: (weakSelf.birthdateTextField.text ?? "").count > 0 ? weakSelf.birthdateTextField.datePicker.date.toYYYYMMDDStringWithHyphen() : nil, gender: UserForAdd.Gender.allValues[weakSelf.genderTextFieldPullDown.selectedIndex ?? 0], fcmToken: Messaging.messaging().fcmToken)

            CmyUserAPI.registerUser(
                body: inUsr,
                completion: { (_, err) in
                    
                    weakSelf.myIndicator.stopAnimatingEx(sender: weakSelf.nextButton)
                    
                    if let err = CmyAPIClient.errorInfo(error: err) {
                        CmyMsgViewController.showError(sender: self, error:err, extra: nil/*"MaldikaBiletoサーバへユーザ登録に失敗しました。"*/)
                        return
                    }

                    weakSelf.myIndicator.startAnimatingEx(sender: weakSelf.nextButton)

                    //登録後のユーザ情報を取得し、メモリ上に保持しておく
                    CmyUserAPI.getUser(completion: { (newUser, error2) in
                        weakSelf.myIndicator.stopAnimatingEx(sender: weakSelf.nextButton)
                        if let err2 = CmyAPIClient.errorInfo(error: error2) {
                            CmyMsgViewController.showError(sender: self, error:err2, extra: nil)
                            return
                        }
                        
                        CmyAPIClient.MaldikaBiletoUser = newUser
                        //パスコード有無のチェック
                        weakSelf.checkPasscodeSetting(){
                            weakSelf.dismiss(animated: true, completion: nil)
                        }
                    })
            })
        })
        super.prepare(for: segue, sender: sender)
    }

//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        //遷移先がチケット発行プレビューの場合、画面入力位チェックを行う
//        return self.validateInputDara()
//    }
    

    
    //画面入力チェック
    //
    private func validateInputDara() -> Bool {
        let bStat: Bool = false
        
        //年齢判定し、16歳以下の場合、
        //警告表示し,以降の処理を実施しない
        
        let newDate = Calendar.current.date(byAdding: .year, value: 16,
                                            to: Calendar.current.startOfDay(for: self.birthdateTextField.datePicker.date))
        if newDate! > Date() {
            CmyMsgViewController.showWarn(sender: self, msg: "１６歳以下の場合、コモニーのサービスが使えません。", title: "")
            return bStat
        }
        return bStat
    }
    

}

extension CmyUserProfileRegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !(textField is CmyTextFieldPullDown) {
            self.genderTextFieldPullDown.pulldown.isHidden = true
        }
        if textField == self.nicknameTextField {
            nextStatA = ((textField.text?.count)! > 0) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.nicknameTextField {
            nextStatA = (textField.text! as NSString).replacingCharacters(in: range, with: string).count > 0 ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CmyUserProfileRegistrationViewController: CmyTextFieldDatePickerDelegate {
    func datePicker(datePicker: CmyTextFieldDatePicker, done: Bool) {
        if done {
            //nextStatB = ((datePicker.text?.count)! > 0 ) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
}

extension CmyUserProfileRegistrationViewController: CmyTextFieldPullDownDelegate {
    func pulldown(pulldown: CmyTextFieldPullDown, done: Bool) {
        if done {
            //nextStatC = ((pulldown.text?.count)! > 0 ) ? true : false
            self.nextButton.isEnabled = (nextStatA && nextStatB && nextStatC) ? true: false
        }
    }
}
