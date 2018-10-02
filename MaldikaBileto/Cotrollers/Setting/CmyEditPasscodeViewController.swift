//
//  CmyEditPasscodeViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/15.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyEditPasscodeViewController: CmyViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewFooterSummaryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        self.tableView.register(SecurityInfoCell.nib, forCellReuseIdentifier: SecurityInfoCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //
        _ = self.tableViewFooterSummaryView.addBorder(toSide: .top, withColor: UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.1), andThickness: 3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController != nil {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
        }
        self.sourceViewController?.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "EditPasscode.navigationbar.top.title", commenmt: "セキュリティ管理")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == CmySegueIds.editPasscodeSegue.rawValue {
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
                                                        let tutorialVC = UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.tutorialNav.rawValue)
                                                        CmyViewController.mainViewController?.present(tutorialVC, animated: true) {
                                                            CmyViewController.mainViewController?.tabBarController?.selectedIndex = 1
                                                        }
                                                    }
                                                    
                    })
                }
            }
            self.present(destVC!, animated: true, completion: nil)
        }
        super.prepare(for: segue, sender: sender)
    }
}

// MARK: UITableViewDataSource
//
extension CmyEditPasscodeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SecurityInfoCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "SecurityInfoCell", for: indexPath) as? SecurityInfoCell
        cell?.segueId = CmySegueIds.editPasscodeSegue
        
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
}

// MARK: UITableViewDelegate
//
extension CmyEditPasscodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        let cell = tableView.cellForRow(at: indexPath) as! SecurityInfoCell
        if cell.segueId != nil {
            self.performSegue(withIdentifier: cell.segueId.rawValue, sender: indexPath)
        }
    }
}

