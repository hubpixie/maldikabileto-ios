//
//  CmyEditGenderViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/22.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditGenderViewController: CmyViewController {

    @IBOutlet weak var genderTextFieldPullDown: CmyTextFieldPullDown!
    @IBOutlet weak var okButton: RoundRectButton!
    
    var dismissHandler: ((_ updated: Bool)->())!
    private var dbUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //性別プルダウン
        self.setupGenderDropDown()
        // OKボタン
        self.okButton.isEnabled = ((self.genderTextFieldPullDown.text?.count ?? 0) > 0)
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        // その他
        self.genderTextFieldPullDown.pickerDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditGender.navigationbar.top.title", commenmt: "性別　変更")
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
    
    // 性別プルダウンを設定
    //
    func setupGenderDropDown() {
        let listStr = CmyLocaleUtil.shared.localizedMisc(key: "UserProfileRegistration.genderTextField.dropdown.list", commenmt: "性別")
        let list = listStr.components(separatedBy: ",")
        self.genderTextFieldPullDown.list = list
        self.genderTextFieldPullDown.setupPulldown(parentView: self.view)
        self.genderTextFieldPullDown.setBottomBorder()
        
        //初期値
        if let gender = CmyAPIClient.MaldikaBiletoUser?.gender,  let idx: Int = User.Gender.allValues.index(of: gender)  {
            self.genderTextFieldPullDown.text = list[idx]
        }
        // delegate
        self.genderTextFieldPullDown.delegate = self
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
            let updUser: UserForUpdate = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: UserForUpdate.Gender.allValues[(self?.genderTextFieldPullDown.selectedIndex)!], email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)
            
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

extension CmyEditGenderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        return false
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
        textField.resignFirstResponder()
        return true
    }
}


extension CmyEditGenderViewController: CmyTextFieldPullDownDelegate {
    func pulldown(pulldown: CmyTextFieldPullDown, done: Bool) {
        if done {
            self.okButton.isEnabled = (self.genderTextFieldPullDown.text?.count ?? 0 > 0)
        }
    }
}
