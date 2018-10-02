//
//  CmyEditBirthdayViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/22.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditBirthdayViewController: CmyViewController {
    @IBOutlet weak var birthdateTextField: CmyTextFieldDatePicker!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        // 生年月日
        self.birthdateTextField.setupDatePicker(parentView: self.view)
        self.birthdateTextField.datePicker.maximumDate = Date()
        self.birthdateTextField.text = { () -> String? in
            if let birthday: String = CmyAPIClient.MaldikaBiletoUser?.birthday {
                return birthday.replacingOccurrences(of: "-", with: "/")
            } else {
                return ""
            }
        }()
        self.birthdateTextField.datePicker.date = CmyAPIClient.MaldikaBiletoUser?.birthday?.convertToDate() ?? Date()
        self.birthdateTextField.setBottomBorder()
        self.birthdateTextField.pickerDelegate = self
        
        // OKボタン
        self.okButton.isEnabled = ((self.birthdateTextField.text?.count ?? 0) > 0)
        
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditBirthday.navigationbar.top.title", commenmt: "生年月日変更")
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
    
    
    @IBAction func okButtonDidTap(_ sender: UIButton) {
        //user idToken
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            self?.myIndicator.startAnimatingEx(sender: sender)

            //MaldikaBiletoにアカウント情報を変更
            let updUser: UserForUpdate = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: (self?.birthdateTextField.text ?? "").count > 0 ? self?.birthdateTextField.datePicker.date.toYYYYMMDDStringWithHyphen() : nil, gender: nil, email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)
            
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

extension CmyEditBirthdayViewController: CmyTextFieldDatePickerDelegate {
    func datePicker(datePicker: CmyTextFieldDatePicker, done: Bool) {
        if done {
            self.okButton.isEnabled = (self.birthdateTextField.text?.count ?? 0 > 0) ? true: false
        }
    }
}


