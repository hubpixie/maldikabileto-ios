//
//  CmyPhoneAuthViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/03.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEnterAuthenticationCodeViewController: CmyViewController {

    @IBOutlet weak var smsCodeInputTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var nextButton: RoundRectButton!
    @IBOutlet weak var approveCheckButton: CheckButton!
    @IBOutlet weak var approveTitleLabel: CmyLinkableLabel!

    var verificationID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        // Do any additional setup after loading the view.
        //
        self.resetNavigationItemTitle()

        //認証コード入力用テキストフィルドの設定
        self.smsCodeInputTextField.setBottomBorder()
        self.smsCodeInputTextField.frame.size.height = 50
        self.smsCodeInputTextField.delegate = self

        //利用規約同意チェックボックスの設定
        self.setApproveCheckTitleAsLink()

        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        // 前画面のタイトルをリセットする
        self.sourceViewController?.resetNavigationItemTitle()
        
        super.viewWillDisappear(animated)
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
            self.smsCodeInputTextField.endEditing(true)
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

    //
    //利用規約同意チェックボックス（タイトル）の設定
    func setApproveCheckTitleAsLink() {
        var chkTitle: String
        let attrText: NSMutableAttributedString = NSMutableAttributedString()
        var subAttrStr: NSAttributedString = NSAttributedString()
        var linkData: [String: String] = [:]
        chkTitle = CmyLocaleUtil.shared.localizedMisc(key: "EnterAuthentication.approveCheckButton.text.1", commenmt: "利用規約")
        var titleArr = chkTitle.components(separatedBy: ",")
        subAttrStr = NSAttributedString(string: String(titleArr[0]))
        attrText.append(subAttrStr)
        _ = attrText.setAsLink(inText: String(titleArr[0]), linkURL: String(titleArr[1]))
        linkData[String(titleArr[1])] = String(titleArr[0])
        chkTitle = CmyLocaleUtil.shared.localizedMisc(key: "EnterAuthentication.approveCheckButton.text.2", commenmt: "および")
        _ = attrText.append(NSAttributedString(string: chkTitle))

        chkTitle = CmyLocaleUtil.shared.localizedMisc(key: "EnterAuthentication.approveCheckButton.text.3", commenmt: "プライバシー")
        titleArr = chkTitle.components(separatedBy: ",")
        subAttrStr = NSAttributedString(string: String(titleArr[0]))
        attrText.append(subAttrStr)
        _ = attrText.setAsLink(inText: String(titleArr[0]), linkURL: String(titleArr[1]))
        linkData[String(titleArr[1])] = String(titleArr[0])

        chkTitle = CmyLocaleUtil.shared.localizedMisc(key: "EnterAuthentication.approveCheckButton.text.4", commenmt: "に同意します")
        _ = attrText.append(NSAttributedString(string: chkTitle))

        //AttributeString
        self.approveTitleLabel.attributedText = attrText
        // if 4-inch device, make font size smaller for approveTitleLabel
        if UIScreen.main.bounds.width <= 320 {
            self.approveTitleLabel.font = UIFont.systemFont(ofSize: self.approveTitleLabel.font.pointSize - 3)
        }
        self.approveTitleLabel.textColor = UIColor.cmyMainColor()

        //keep all lioks
        for (key, value) in linkData {
            let range: NSRange = (attrText.string as NSString).range(of: value)
            self.approveTitleLabel.addLink(url: key, atRange: range)
        }
        
        self.approveTitleLabel.delegate = self
        self.approveCheckButton.delegate = self
    }
    
    /// 画面遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mySeg = segue as! CmyPushFadeSegue
        guard let vid = self.verificationID, let vcd = self.smsCodeInputTextField.text else {return}
        mySeg.extraHandler = { [weak self] () in
            guard let weakSelf = self else {return}
            
            weakSelf.myIndicator.startAnimatingEx(sender: sender)
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: vid, verificationCode: vcd)
            Auth.auth().useAppLanguage()
            
            //電話番号でログイン
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                
                if let error = error {
                    CmyMsgViewController.showError(sender: weakSelf, error:error, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "EnterAuthentication.smsCodeInputTextField.check.1", commenmt: "SM認証コード入力エラー")*/)
                    return
                }
                weakSelf.myIndicator.startAnimatingEx(sender: sender)
                
                Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
                    weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    weakSelf.myIndicator.startAnimatingEx(sender: sender)

                    // fetch MaldikaBileto user
                    CmyUserAPI.getUser(completion: { (user, err) in
                        weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                        
                        if let err = CmyAPIClient.errorInfo(error: err), err.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                            CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*"MaldikaBiletoサーバからユーザ取得に失敗しました。"*/)
                            return
                        }
                        
                        //ユーザが存在する場合
                        CmyAPIClient.MaldikaBiletoUser = user
                        // MaldikaBileto API Client setting when firebase signining
                        CmyAPIClient.setup()

                        if let _ = user {
                            //ログイン画面へ
                            weakSelf.clearNavigationItemTitle()
                            let vc = weakSelf.moveNextViewController(vcIdentifier: CmyStoryboardIds.userLogin.rawValue) as! CmyViewController
                            vc.sourceViewController = weakSelf
                        } else {
                            //電話番号以外の プロバイダ有無確認
                            if let providers = Auth.auth().currentUser?.providerData
                                .filter({ (userInfo: UserInfo) in return userInfo.providerID != PhoneAuthProviderID})
                                .map({ (userInfo: UserInfo) in return userInfo.uid}), providers.count > 0
                                 {
                                let vc = self?.moveNextViewController(vcIdentifier: CmyStoryboardIds.userProfileRegistration.rawValue) as! CmyViewController
                                weakSelf.clearNavigationItemTitle()
                                vc.sourceViewController = weakSelf
                            } else {
                                // メール・SNS認証画面へ
                                let vc = mySeg.destination as! CmyViewController
                                weakSelf.clearNavigationItemTitle()
                                vc.sourceViewController = weakSelf
                                mySeg.source.navigationController?.pushViewController(mySeg.destination, animated: false)
                            }
                        }
                    })
                })
            })
        }
        super.prepare(for: segue, sender: sender)
    }

}

extension CmyEnterAuthenticationCodeViewController: CmyTappableLabelDelegate {
    func tappableLabel(tabbableLabel: CmyLinkableLabel, didTapUrl: URL, atRange: NSRange) {
        let url = didTapUrl.absoluteString
        let pageTitle = (tabbableLabel.text as NSString?)?.substring(with: atRange)
        CmyWebViewController.openUrl(source: self, url: url, pageTitle: pageTitle)
    }
}

extension CmyEnterAuthenticationCodeViewController: CheckButtonDelegate {
    func checkButton(checkButton: CheckButton, checked: Bool) {
        if checkButton == self.approveCheckButton {
            //self.approveTitleLabel.isEnabled = checked
            self.approveTitleLabel.isUserInteractionEnabled = true
            self.nextButton.isEnabled = (self.smsCodeInputTextField.text?.count == self.smsCodeInputTextField.maxLength && self.approveCheckButton.isChecked)
        }
    }
}

extension CmyEnterAuthenticationCodeViewController: UITextFieldDelegate {
    
    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 文字数最大を決める.
        let maxLength: Int = self.smsCodeInputTextField.maxLength
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = String.replacingInsertingAtRange(range, of: textField.text, with: string)

        // 文字数がmaxLength以下ならtrueを返す.
        self.nextButton.isEnabled = (str.count >= maxLength && self.approveCheckButton.isChecked)
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

