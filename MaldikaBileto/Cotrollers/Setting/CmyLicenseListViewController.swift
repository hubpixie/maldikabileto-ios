//
//  CmyLicenseListViewController.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/09/22.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit

class CmyLicenseListViewController: CmyViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var licenseArray: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        self.licenseArray = self.getLicenseData()
        
        // setup table view
        self.tableView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.register(AppSettingItemCell.nib, forCellReuseIdentifier: AppSettingItemCell.identifier)

        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if !self.seguePrepared {
            if self.sourceViewController != nil {
                // タイトル設定
                self.sourceViewController?.resetNavigationItemTitle()
            }
            self.sourceViewController?.tabBarController?.tabBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "LicenseList.navigationbar.top.title", commenmt: "ライセンス")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.seguePrepared = true
        
        guard let indexPath: IndexPath = sender as? IndexPath else {return}
        let cell = self.tableView.cellForRow(at: indexPath) as! AppSettingItemCell

        let mySegue = segue as! CmyPushFadeSegue
        mySegue.extraHandler = {
            let destVC = segue.destination as! CmyLicenseDetailViewController
            if cell.segueId == CmySegueIds.licenseDetailSegue {
                let licenseItem = self.getLicenseItem(
                    itemKey: self.licenseArray[indexPath.row]["File"] as! String,
                    title: self.licenseArray[indexPath.row]["Title"] as! String
                )
                destVC.licenseItem = licenseItem
            }
            destVC.sourceViewController = self
            self.clearNavigationItemTitle()
            self.navigationController?.pushViewController(segue.destination, animated: true)
        }
        super.prepare(for: segue, sender: sender)

    }
    

    func getLicenseData() -> [[String: Any]] {
        let path = Bundle.main.path(forResource: "CmySettings.bundle/com.mono0926.LicensePlist", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        if let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: Any] {
            if let data = plist["PreferenceSpecifiers"] as? [[String: Any]] {
                return data
            }
        }
        return []
    }
    func getLicenseItem(itemKey: String, title: String) -> [String: Any] {
        let path = Bundle.main.path(forResource: "CmySettings.bundle/\(itemKey)", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        if let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: Any] {
            if let data = plist["PreferenceSpecifiers"] as? [[String: Any]] {
                var item = data[0]
                item["Title"] = title
                return item
            }
        }
        return [:]
    }

}

// MARK: UITableViewDataSource
//
extension CmyLicenseListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AppSettingItemCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: AppSettingItemCell.identifier, for: indexPath) as? AppSettingItemCell
        cell?.itemLabel.text = self.licenseArray[indexPath.row]["Title"] as? String
        cell?.segueId = CmySegueIds.licenseDetailSegue

        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
}

// MARK: UITableViewDelegate
//
extension CmyLicenseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        let cell = tableView.cellForRow(at: indexPath) as! AppSettingItemCell
        cell.preventDoubleTap()

        self.performSegue(withIdentifier: cell.segueId.rawValue, sender: indexPath)
    }
}
