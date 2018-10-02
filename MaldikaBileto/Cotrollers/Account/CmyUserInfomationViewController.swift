//
//  CmyUserInfomationViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyUserInfomationViewController: CmyViewController {
    private enum SectionNumber: Int {
        case profile = 0
        case logout = 1
        case withdrawal = 2
    }
    private enum AccountProfileCellIdentifier: Int {
        case headerCell = 0
        case nicknameCell = 1
        case birthdayCell = 2
        case genderCell = 3
        case phoneNumberCell = 4
        case emailExtraCell = 5
        case passwordCell = 6
        case snsAuthCell = 7
        static var allValues: [String] = [AccountProfileInfoCell.identifier, AccountProfileNicknameCell.identifier, AccountProfileBirthdayCell.identifier, AccountProfileGenderCell.identifier, AccountProfilePhoneNumberCell.identifier, AccountProfEmailExtraCell.identifier, AccountProfilePasswordCell.identifier, AccountProfileSNSAuthCell.identifier]
        static var allNibs: [UINib] = [AccountProfileInfoCell.nib, AccountProfileNicknameCell.nib, AccountProfileBirthdayCell.nib, AccountProfileGenderCell.nib, AccountProfilePhoneNumberCell.nib, AccountProfEmailExtraCell.nib, AccountProfilePasswordCell.nib, AccountProfileSNSAuthCell.nib,]
        static var allSegues: [CmySegueIds] = [CmySegueIds.none, CmySegueIds.editUserNicknameSegue, CmySegueIds.editBirthdaySegue, CmySegueIds.editGenderSegue, CmySegueIds.editPhoneNumberSegue, CmySegueIds.editMailAddressSegue, CmySegueIds.editPasswordSegue,CmySegueIds.editSnsLinkageSegue]
    }
    private var TableSectionTitles: [String]!

    @IBOutlet weak var tableView: UITableView!
    
    //ログアウト制御用のコールバック
    var logoutHandler: ((_ enabled: Bool)->())!
    private var enablesLogout: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //setup tableview items
        self.tableView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.setupAccountItems()
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //最新のユーザ情報を主と得する
        self._getMaldikaBiletoUser() {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "UserInfomation.navigationbar.top.title", commenmt: "Setting")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // タブバーを表示する
        if !self.seguePrepared {
            if self.sourceViewController is CmyAppSettingsViewController {
                self.sourceViewController?.tabBarController?.tabBar.isHidden = false
                self.sourceViewController?.resetNavigationItemTitle()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.logoutHandler?(self.enablesLogout)
        super.viewDidDisappear(animated)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.seguePrepared = true
        
        guard  let indexPath: IndexPath = sender as? IndexPath else {return}
        let dismissHandler: ((_ updated: Bool)->())! = {(updated) in
            if updated {
                self.myIndicator.startAnimatingEx(sender: nil)
                
                //カレントユーザ取得
                self._getMaldikaBiletoUser() {
                    //テーブル表示をリフレッシュする
                    self.tableView.reloadData()
                    self.tabBarController?.tabBar.isHidden = false
                    self.myIndicator.stopAnimatingEx(sender: nil)
                }
            }
        }
        
        // 次画面をモードレス(show / push)で表示する場合
        // ＜プロフィール関連＞
        if let mySegue: CmyPushFadeSegue = segue as? CmyPushFadeSegue {
            mySegue.extraHandler = {
                if indexPath.section == SectionNumber.profile.rawValue {
                    switch indexPath.row {
                    case AccountProfileCellIdentifier.nicknameCell.rawValue:
                        let destVC = segue.destination as! CmyEditUserNicknameViewController
                        destVC.dismissHandler = dismissHandler
                    case AccountProfileCellIdentifier.birthdayCell.rawValue:
                        let destVC = segue.destination as! CmyEditBirthdayViewController
                        destVC.dismissHandler = dismissHandler
                    case AccountProfileCellIdentifier.genderCell.rawValue:
                        let destVC = segue.destination as! CmyEditGenderViewController
                        destVC.dismissHandler = dismissHandler
                    case AccountProfileCellIdentifier.phoneNumberCell.rawValue:
                        let destVC = segue.destination as! CmyEditPhoneNumberViewController
                        destVC.dismissHandler = dismissHandler
                    case AccountProfileCellIdentifier.emailExtraCell.rawValue:
                        if segue.identifier == CmySegueIds.editMailAddressSegue.rawValue {
                            let destVC = segue.destination as! CmyEditMailAddressViewController
                            destVC.dismissHandler = dismissHandler
                        } else {
                            let destVC = segue.destination as! CmyAddMailAddressViewController
                            destVC.dismissHandler = dismissHandler
                        }
                    case AccountProfileCellIdentifier.passwordCell.rawValue:
                        let destVC = segue.destination as! CmyEditPasswordViewController
                        destVC.dismissHandler = dismissHandler
                    case AccountProfileCellIdentifier.snsAuthCell.rawValue:
                        let destVC = segue.destination as! CmyEditSnsLinkageViewController
                        destVC.dismissHandler = dismissHandler
                    default:
                        break
                    }
                    
                }
                let vc = segue.destination as! CmyViewController
                vc.sourceViewController = self
                self.tabBarController?.tabBar.isHidden = true
                self.clearNavigationItemTitle()
                self.navigationController?.pushViewController(segue.destination, animated: true)
            }
        }
        
        // 次画面をモーダルで表示する場合
        if let mySegue = segue as? CmyPresentSegue {
            // ＜退会関連＞
            if indexPath.section == SectionNumber.withdrawal.rawValue {
                let destVC = mySegue.destination as! CmyWithdrawalConfirmController
                destVC.isUserDismissEnabled = true
                destVC.okAction = {
                    self.seguePrepared = false
                    
                    self.myIndicator.startAnimatingEx(sender: nil)
                    //未使用のチケットを確認
                    // 仕様変更：未使用チケットのチェックはAPI内部にて行われているため、
                    // クライアント側でチェックせずにチョックユーザ削除しに行きます
                    Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
                        self?.myIndicator.stopAnimatingEx(sender: nil)
                        guard let weakSelf = self else {return}
                        if !CmyAPIClient.prepareHeaders(sender: destVC, idToken: idToken, error:  error) {return}
 
                            self?.myIndicator.startAnimatingEx(sender: nil)
                            //退会処理を行う
                            CmyUserAPI.deleteUser(completion: { (_, error3) in
                                self?.myIndicator.stopAnimatingEx(sender: nil)

                                if let err = CmyAPIClient.errorInfo(error: error3) {
                                    //未使用チケットあるため、退会できないとする
                                    let show_unused_ticket_proc = {
                                        let resultVC: CmyWithdrawalResultAlertController = CmyWithdrawalResultAlertController()
                                        resultVC.okAction = {
                                            destVC.dismiss(animated: true) {
                                                self?.sourceViewController?.tabBarController?.tabBar.isHidden = false
                                                self?.navigationController?.popViewController(animated: true)
                                                //Ticket Listへ
                                                CmyViewController.mainViewController?.tabBarController?.selectedIndex = 1
                                            }
                                        }
                                        resultVC.cancelAction = {
                                            destVC.dismiss(animated: true, completion: nil)
                                        }
                                        destVC.present(resultVC, animated: false, completion: nil)
                                    }
                                    
                                    if err.0 == CmyAPIClient.HttpStatusCode.unusedTickets.rawValue { //未使用チケットあり
                                        show_unused_ticket_proc()
                                        return
                                    } else {
                                        CmyMsgViewController.showError(
                                            sender: destVC,
                                            error:err,
                                            extra: nil /*CmyLocaleUtil.shared.localizedMisc(key: "UserInfomation.view.check.3", commenmt: "退会処理")*/)
                                        return
                                    }
                                }
                                CmyMsgViewController.showMsg(sender: destVC,
                                                             msg:  CmyLocaleUtil.shared.localizedMisc(key: "UserInfomation.tableView.section.withdrawal.message", commenmt: "退会済み"),
                                                             title:"")
                                {(action) in
                                    // ログアウト処理を実施する
                                    CmyAPIClient.MaldikaBiletoUser = nil
                                    destVC.dismiss(animated: true) {
                                        weakSelf.enablesLogout = true
                                        weakSelf.navigationController?.popViewController(animated: true)
                                    }
                                }
                            })
                    })

                }
                
                destVC.cancelAction = {
                    self.seguePrepared = false
                }
                self.present(destVC, animated: true, completion: nil)
            }
        }
        super.prepare(for: segue, sender: sender)
    }
 
    // 設定一覧表示用データを用意する
    //
    func setupAccountItems() {
        //セクションタイトルを取得する
        let title: String = CmyLocaleUtil.shared.localizedMisc(key: "UserInfomation.tableView.section.titles", commenmt: "セクションタイトル")
        self.TableSectionTitles = title.components(separatedBy: ",")
        
        //set cells and data
        // - プロフィールセクション
        for i in 0 ..< AccountProfileCellIdentifier.allValues.count {
            self.tableView.register(AccountProfileCellIdentifier.allNibs[i], forCellReuseIdentifier: AccountProfileCellIdentifier.allValues[i])
        }
        // - ログアウトセクション
        self.tableView.register(AccountLogoutCell.nib, forCellReuseIdentifier: AccountLogoutCell.identifier)
        // - 退会セクション
        self.tableView.register(AccountWithdrawCell.nib, forCellReuseIdentifier: AccountWithdrawCell.identifier)
        
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    // メールアドレス表示用文字列取得
    //
    private func _getEmailString() -> String {
        if let email = CmyAPIClient.MaldikaBiletoUser?.email {
            if let verified = CmyAPIClient.MaldikaBiletoUser?.emailVerified, verified {
                return String(format: "%@ (%@)", email, CmyLocaleUtil.shared.localizedMisc(key: "Common.hasVerified.label", commenmt: "認証済み"))
            } else {
                return String(format: "%@ (%@)", email, CmyLocaleUtil.shared.localizedMisc(key: "Common.hasNotVerified.label", commenmt: "未認証"))
            }
        } else {
            return CmyLocaleUtil.shared.localizedMisc(key: "Common.hasNotValue.label", commenmt: "未設定")
        }
    }
    
    // メールアドレス認証状態表示用文字列取得
    //
    private func _getEmailVerifirationState() -> Bool {
        if let _ = CmyAPIClient.MaldikaBiletoUser?.email {
            return CmyAPIClient.MaldikaBiletoUser?.emailVerified ?? false
        } else {
            return true
        }
    }

    private func _getMaldikaBiletoUser(completionHandler: (()->())?) {
        //user idToken
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}

            //MaldikaBiletoサーバからユーザ情報を取得する
            CmyUserAPI.getUser(
                completion: { (user, err) in
                    if let err = CmyAPIClient.errorInfo(error: err), err.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                        CmyMsgViewController.showError(sender: self, error:err, extra: nil /*"MaldikaBiletoサーバからユーザ取得に失敗しました。"*/)
                        return
                    }
                    CmyAPIClient.MaldikaBiletoUser = user
                    completionHandler?()
            })
        })
    }
}

// MARK: UITableViewDataSource
//
extension CmyUserInfomationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionNumber.profile.rawValue {
            return AccountProfileCellIdentifier.allValues.count
        } else if section == SectionNumber.logout.rawValue {
            return 1
        } else if section == SectionNumber.withdrawal.rawValue {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var cellId: String!
        
        //「プロフィール」セクション
        if indexPath.section == SectionNumber.profile.rawValue {
            cellId = AccountProfileCellIdentifier.allValues[indexPath.row]
            switch indexPath.row {
            case AccountProfileCellIdentifier.headerCell.rawValue:
                cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            case AccountProfileCellIdentifier.nicknameCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfileNicknameCell
                c?.itemValueLabel.text = CmyAPIClient.MaldikaBiletoUser?.nickname; cell = c
                cell?.accessoryType = .disclosureIndicator
            case AccountProfileCellIdentifier.birthdayCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfileBirthdayCell
                c?.itemValueLabel.text = { () -> String? in
                    if let birthday: String = CmyAPIClient.MaldikaBiletoUser?.birthday {
                        return birthday.replacingOccurrences(of: "-", with: "/")
                    } else {
                        return ""
                    }
                }()
                cell = c
                cell?.accessoryType = .disclosureIndicator
            case AccountProfileCellIdentifier.genderCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfileGenderCell
                c?.itemValueLabel.text = {() -> String? in
                    let listStr = CmyLocaleUtil.shared.localizedMisc(key: "UserProfileRegistration.genderTextField.dropdown.list", commenmt: "性別")
                    let list = listStr.components(separatedBy: ",")
                    if let gender = CmyAPIClient.MaldikaBiletoUser?.gender, let idx: Int = User.Gender.allValues.index(of: gender) {
                        return list[idx]
                    } else {
                        return ""
                    }
                }()
                cell = c
                cell?.accessoryType = .disclosureIndicator
            case AccountProfileCellIdentifier.phoneNumberCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfilePhoneNumberCell
                c?.itemValueLabel.text = CmyAPIClient.MaldikaBiletoUser?.phoneNumber; cell = c
                cell?.accessoryType = .disclosureIndicator
            case AccountProfileCellIdentifier.emailExtraCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfEmailExtraCell
                c?.itemValue = self._getEmailString()
                c?.emailVerified = self._getEmailVerifirationState()
                AccountProfileCellIdentifier.allSegues[indexPath.row] = (Auth.auth().currentUser?.email == nil) ? CmySegueIds.addMailAddressSegue : CmySegueIds.editMailAddressSegue
                c?.delegate = self
                cell = c
                cell?.accessoryType = .disclosureIndicator
                
            case AccountProfileCellIdentifier.passwordCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfilePasswordCell
                c?.itemValueLabel.text = {() -> String? in
                        if let _ = CmyAPIClient.MaldikaBiletoUser?.email {
                            return CmyLocaleUtil.shared.localizedMisc(key: "Common.hasValue.label", commenmt: "設定済")
                        } else {
                            return CmyLocaleUtil.shared.localizedMisc(key: "Common.hasNotValue.label", commenmt: "未設定")
                        }
                    }()
                cell = c
                cell?.isHidden = (CmyAPIClient.MaldikaBiletoUser?.email == nil)
                cell?.accessoryType = .disclosureIndicator
                
            case AccountProfileCellIdentifier.snsAuthCell.rawValue:
                let c = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountProfileSNSAuthCell
                c?.itemValueLabel.text = {() -> String? in
                    if let providers = Auth.auth().currentUser?.providerData
                        .filter({ (userInfo: UserInfo) in
                            return userInfo.providerID != PhoneAuthProviderID
                            && userInfo.providerID != EmailAuthProviderID
                        }).map({ (userInfo: UserInfo) in return userInfo.uid}), providers.count > 0
                    {
                        return CmyLocaleUtil.shared.localizedMisc(key: "Common.hasValue.label", commenmt: "設定済")
                    } else {
                        return CmyLocaleUtil.shared.localizedMisc(key: "Common.hasNotValue.label", commenmt: "未設定")
                    }
                }()
                cell = c
                cell?.accessoryType = .disclosureIndicator
 
            default:
                break
            }
        }
        //「ログアウト」セクション
        if indexPath.section == SectionNumber.logout.rawValue {
            cell = tableView.dequeueReusableCell(withIdentifier: AccountLogoutCell.identifier, for: indexPath)
            cell?.accessoryType = .disclosureIndicator
        }

        //「退会」セクション
        if indexPath.section == SectionNumber.withdrawal.rawValue {
            cell = tableView.dequeueReusableCell(withIdentifier: AccountWithdrawCell.identifier, for: indexPath)
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
}

// MARK: UITableViewDelegate
//
extension CmyUserInfomationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.preventDoubleTap()
        
        //「プロフィール」セクション
        if indexPath.section == SectionNumber.profile.rawValue && indexPath.row > AccountProfileCellIdentifier.headerCell.rawValue {
            self.performSegue(withIdentifier: AccountProfileCellIdentifier.allSegues[indexPath.row].rawValue, sender: indexPath)
        }

        //「ログアウト」セクション
        if indexPath.section == SectionNumber.logout.rawValue {
            self.enablesLogout = true
            self.navigationController?.popViewController(animated: true)
        }

        //「退会」セクション
        if indexPath.section == SectionNumber.withdrawal.rawValue {
            self.prepare(for: CmyPresentSegue(identifier: nil,
                                              source: self,
                                              destination: CmyWithdrawalConfirmController()),
                         sender: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == SectionNumber.withdrawal.rawValue { //「退会」セクション
            return UIView()
        } else {
            let footerView = UIView()
            footerView.backgroundColor = UIColor.white
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeigth = tableView.rowHeight
        
        //メール認証セルの高さを取得する
        if indexPath.section == SectionNumber.profile.rawValue && indexPath.row == AccountProfileCellIdentifier.emailExtraCell.rawValue {
            rowHeigth = AccountProfEmailExtraCell.calcContentsHeight(contentString: self._getEmailString(),
                                                                     emailVerified: self._getEmailVerifirationState())
        }
        //メール未設定場合、パスワードセルを表示しないとする
        rowHeigth = (indexPath.row == AccountProfileCellIdentifier.passwordCell.rawValue && CmyAPIClient.MaldikaBiletoUser?.email == nil) ? 0 : rowHeigth
        return rowHeigth
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.cmyTitleColor()
    }
}

// MARK: AccountEditEmailDelegate
//
extension CmyUserInfomationViewController: AccountEditEmailDelegate {
    //認証メール送信時処理
    func resendEmailVerification(cell: AccountProfEmailExtraCell) {
        //let indexPath = self.tableView.indexPath(for: cell)
        Auth.auth().currentUser?.sendEmailVerification(completion: {[weak self] (error2) in
            if let err2 = error2 {
                CmyMsgViewController.showError(sender: self, error:err2, extra:nil)
            } else {
                //認証メールアラートを表示させる
                CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "UserRegistration.nextButton.sendMail.message" ,commenmt: "メール未認証"), title: "認証メール") {(action) in
                    
                }
            }
        })
    }
    
    // emailアドレス変更時処理
    func emailWillChange(cell: AccountProfEmailExtraCell) {
        cell.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cell.isUserInteractionEnabled = true
        }
        if let indexPath = self.tableView.indexPath(for: cell)  {
            self.performSegue(withIdentifier: AccountProfileCellIdentifier.allSegues[indexPath.row].rawValue, sender: indexPath)
        }
    }
}
