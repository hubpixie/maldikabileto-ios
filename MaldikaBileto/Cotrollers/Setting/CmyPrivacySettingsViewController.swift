//
//  CmyPrivacySettingsViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/14.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyPrivacySettingsViewController: CmyViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewFooterSummaryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        self.tableView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.register(PrivacyInfoCell.nib, forCellReuseIdentifier: PrivacyInfoCell.identifier)
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "PrivacySettings.navigationbar.top.title", commenmt: "プライバシー管理")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == CmySegueIds.passcodeLockSegue.rawValue {
            if CmyUserDefault.shared.passcodeSetting.passcode.isEmpty {
                let destVC = PasscodeBundle(window: nil).makeCode()
                self.present(destVC!, animated: true, completion: nil)
            } else {
                let destVC = PasscodeBundle(window: nil).authenticate()
                self.present(destVC!, animated: true, completion: nil)
            }
        }
        super.prepare(for: segue, sender: sender)
    }
}

// MARK: UITableViewDataSource
//
extension CmyPrivacySettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PrivacyInfoCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyInfoCell", for: indexPath) as? PrivacyInfoCell
        cell?.segueId = CmySegueIds.passcodeLockSegue
        
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        return cell!
    }
}

// MARK: UITableViewDelegate
//
extension CmyPrivacySettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        let cell = tableView.cellForRow(at: indexPath) as! PrivacyInfoCell
        cell.preventDoubleTap()

        if !cell.passcodeLockSwitch.isOn {return}
        if cell.segueId != nil {
            self.performSegue(withIdentifier: cell.segueId.rawValue, sender: indexPath)
        }
    }
}

