//
//  CmyAppSettingsViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyAppSettingsViewController: CmyViewController {

    private enum AccountCellIdentifier: Int {
        case accountCell = 0
        case paymentCell = 1
        case privacyMngCell = 2
        case securityMngCell = 3
        
        static var allValues: [String] = ["accountCell", "paymentCell", "privacyMngCell", "securityMngCell"]
        static var allSegues: [CmySegueIds] = [CmySegueIds.userInfomationSegue, CmySegueIds.creditCardListSegue, CmySegueIds.privacySettingsSegue, CmySegueIds.securityMngSegue]
    }
    private enum AboutAppCellIdentifier: Int {
        case howtoUseCell = 0
        case helpCell = 1
        case serviceItemsCell = 2
        case privacyPolicyCell = 3
        case licenseCell = 4
        case serviceInfoCell = 5
        static var allValues: [String] = ["howtoUseCell", "helpCell", "serviceItemsCell", "privacyPolicyCell", "licenseCell", "serviceInfoCell"]
        static var allSegues: [CmySegueIds] = [CmySegueIds.howtoUseSegue, CmySegueIds.helpSegue, CmySegueIds.serviceItemsSegue, CmySegueIds.privacyPolicySegue, CmySegueIds.licenseSegue, CmySegueIds.serviceInfoSegue]
    }
    private var TableSectionTitles: [String]!
    private var AccountSectionItemTitles: [String]!
    private var AboutAppSectionItemTitles: [String]!
    private var AboutAppSectionItemUrls: [String]!

    @IBOutlet weak var tableView: UITableView!
    private var aboutAppSectionHeaderView: UITableViewHeaderFooterView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //setup tableview items
        self.tableView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.setupAppSettingItems()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.navigationbar.top.title", commenmt: "Setting")
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let indexPath: IndexPath = sender as? IndexPath else {return}
        let cell = self.tableView.cellForRow(at: indexPath) as! AppSettingItemCell
        
        switch cell.segueId! {
        case .userInfomationSegue:
            let destVC = segue.destination as! CmyUserInfomationViewController
            destVC.logoutHandler = {(enabled) in
                if !enabled  {return}
                guard let splashVC = UIStoryboard.splash().instantiateInitialViewController() else {return}
                CmyViewController.mainViewController?.present(splashVC, animated: true) {
                    sleep(2)
                    splashVC.dismiss(animated: false) {
                        //Firebaseからサインアウトさせる
                        CmyViewController.appDelegate?.signOutFirebseAuth()
                        //アプリ関連キャッシュ情報をクリアする
                        let tutorialVC = UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.tutorialNav.rawValue) as! UINavigationController
                        if CmyAPIClient.MaldikaBiletoUser == nil {
                            CmyUserDefault.shared.cleanUp(userDefaultMode: .all)
                        } else {
                            CmyUserDefault.shared.cleanUp(userDefaultMode: .tutorialShown)
                            tutorialVC.viewControllers = [UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.phoneNumberRegistration.rawValue)]
                        }
                        CmyViewController.mainViewController?.present(tutorialVC, animated: true) {
                            CmyViewController.mainViewController?.tabBarController?.selectedIndex = 1
                        }
                    }
                }
            }
            break
        case .creditCardListSegue:
            break
        case .privacySettingsSegue:
            break
        case .securityMngSegue:
            break
        case .howtoUseSegue, .helpSegue, .serviceItemsSegue, .privacyPolicySegue:
            CmyWebViewController.openUrl(source: self, url: cell.itemUrl!, pageTitle: cell.itemLabel.text)
            return
        case .licenseSegue:
            break
        case .serviceInfoSegue:
            if let urlScheme =  cell.itemUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlScheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        default:
            break
        }
        self.clearNavigationItemTitle()
        self.tabBarController?.tabBar.isHidden = true
        let vc = segue.destination as? CmyViewController
        vc?.sourceViewController = self
        self.navigationController?.pushViewController(segue.destination, animated: true)
    }
    
    // 設定一覧表示用データを用意する
    //
    func setupAppSettingItems() {
        //セクションタイトルを取得する
        let title: String = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section.titles", commenmt: "セクションタイトル")
        self.TableSectionTitles = title.components(separatedBy: ",")
        //「会員管理」セクションの各セルタイトルを取得する
        var itemTitle: String = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_1.cellTitles", commenmt: "会員管理")
        self.AccountSectionItemTitles = itemTitle.components(separatedBy: ",")
        //「アプリについて」セクションの各セルタイトルを取得する
        itemTitle = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.cellTitles", commenmt: "アプリについて")
        self.AboutAppSectionItemTitles = itemTitle.components(separatedBy: ",")
        //「アプリについて」セクションの各セルURLを取得する
        self.AboutAppSectionItemUrls = ["","","","","",""]
        var itemUrl = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.howtoUseCell.url", commenmt: "アプリについて")
        self.AboutAppSectionItemUrls[0] = itemUrl.components(separatedBy: ",")[1]
        itemUrl = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.helpCell.url", commenmt: "アプリについて")
        self.AboutAppSectionItemUrls[1] = itemUrl.components(separatedBy: ",")[1]
        itemUrl = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.serviceItemsCell.url", commenmt: "アプリについて")
        self.AboutAppSectionItemUrls[2] = itemUrl.components(separatedBy: ",")[1]
        itemUrl = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.privacyPolicyCell.url", commenmt: "アプリについて")
        self.AboutAppSectionItemUrls[3] = itemUrl.components(separatedBy: ",")[1]
        itemUrl = CmyLocaleUtil.shared.localizedMisc(key: "AppSettings.tableView.section_2.serviceInfoCell.mailto", commenmt: "アプリについて")
        self.AboutAppSectionItemUrls[5] = String(format: itemUrl.components(separatedBy: ",")[1], (Auth.auth().currentUser?.uid ?? ""))

        //set cells and data
        // - 会員管理セクション
        for i in 0 ..< self.AccountSectionItemTitles.count {
            self.tableView.register(AppSettingItemCell.nib, forCellReuseIdentifier: AccountCellIdentifier.allValues[i])
        }
        // - 「このアプリについて」管理セクション
        for i in 0 ..< self.AboutAppSectionItemTitles.count {
            self.tableView.register(AppSettingItemCell.nib, forCellReuseIdentifier: AboutAppCellIdentifier.allValues[i])
        }

        //「このアプリについえ」セクションのヘッダビューを用意する
        self.aboutAppSectionHeaderView = UITableViewHeaderFooterView()
        let appVerLabel: UILabel  = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 0, width: 60, height: 30))
        appVerLabel.textColor = UIColor.cmyTitleColor()
        appVerLabel.textAlignment = .right
        let verStr: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        appVerLabel.text = "ver \(verStr)"
        self.aboutAppSectionHeaderView.addSubview(appVerLabel)
        
        //appVerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.aboutAppSectionHeaderView.addConstraint(NSLayoutConstraint.init(item: self.aboutAppSectionHeaderView,
                                                                             attribute: NSLayoutAttribute.trailing,
                                                                             relatedBy: NSLayoutRelation.equal,
                                                                             toItem: appVerLabel,
                                                                             attribute: NSLayoutAttribute.trailing,
                                                                             multiplier: 1.0,
                                                                             constant: 22))

        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    //セキュリティ管理画面を表示せずに直接パスコード変更画面を表示させる
    //
    func showPasscodeChange() {
        let destVC = PasscodeBundle(window: nil).changeCode() as? CmyPasscodeSettingViewController
        destVC?.isUserDismissEnabled = true
        destVC?.authenticatedCompletion = {[weak self](result) in
            guard let weakSelf = self else {return}
            if !result {
                //規定入力回数までパスコード入力不正の場合、
                //Firebaseからログアウトさせ、電話番号入力画面へ移動する
                CmyMsgViewController.showMsg(sender: destVC,
                                             msg: CmyLocaleUtil.shared.localizedMisc(key: "PasscodeSetting.authenticate.error.2", commenmt: "入力回数上限チェック"),
                                             title: "", okHandler: {(action) in
                                                weakSelf.navigationController?.dismiss(animated: true) {
                                                    //アプリ関連キャッシュ情報をクリアする
                                                    CmyUserDefault.shared.cleanUp(userDefaultMode: .tutorialShown)
                                                    let tutorialVC = UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.tutorialNav.rawValue) as! UINavigationController
                                                    tutorialVC.viewControllers = [UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.phoneNumberRegistration.rawValue)]

                                                    CmyViewController.mainViewController?.present(tutorialVC, animated: true) {
                                                        CmyViewController.mainViewController?.tabBarController?.selectedIndex = 1
                                                    }
                                                }
                                                
                })
            }
        }
        self.present(destVC!, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
//
extension CmyAppSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.AccountSectionItemTitles.count
        } else if section == 1 {
            return self.AboutAppSectionItemTitles.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AppSettingItemCell?
        var cellId: String!
        var url: String!
        
        //「会員管理」セクション
        if indexPath.section == 0 {
            cellId = AccountCellIdentifier.allValues[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AppSettingItemCell
            cell?.itemLabel.text = self.AccountSectionItemTitles[indexPath.row]
            cell?.segueId = AccountCellIdentifier.allSegues[indexPath.row]
        }
        //「アプリについて」セクション
        if indexPath.section == 1 {
            url = AboutAppSectionItemUrls[indexPath.row]
            cellId = AboutAppCellIdentifier.allValues[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AppSettingItemCell
            
            cell?.itemLabel.text = self.AboutAppSectionItemTitles[indexPath.row]
            cell?.itemUrl = url
            cell?.segueId = AboutAppCellIdentifier.allSegues[indexPath.row]
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.TableSectionTitles[section]
    }
    
}

// MARK: UITableViewDelegate
//
extension CmyAppSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        let cell = tableView.cellForRow(at: indexPath) as! AppSettingItemCell
        cell.preventDoubleTap()

        //セキュリティ管理の場合、画面遷移をせずに直接にパスコード変更画面を開く
        if cell.segueId == CmySegueIds.securityMngSegue {
            self.showPasscodeChange()
        } else {
            self.performSegue(withIdentifier: cell.segueId.rawValue, sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.headerView(forSection: section)
        if section == 1 {
            view = self.aboutAppSectionHeaderView
        } else {
            view = UITableViewHeaderFooterView()
        }
        view?.backgroundView = UIView(frame: (view?.bounds)!)
        view?.backgroundView?.backgroundColor = UIColor.white
        let border = view?.backgroundView?.addBorder(toSide: .bottom,
                                     withColor: UIColor.cmyBottomBorderColor(), andThickness: 1.5)
        border?.frame = CGRect(x: 10, y: 30, width: (border?.frame.width)! - 20, height: (border?.frame.height)!)
        return view
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.cmyTitleColor()
    }

}
