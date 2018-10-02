//
//  CmyInquireListViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/24.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyInquireListViewController: CmyViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var visitedInquireList: InquireList!
    private var visitedRefInquireList: [CmyUserBundle.InquireRef]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController?.tabBarItem.badgeColor = UIColor.red
        self.resetNavigationItemTitle()

//        self.navigationController?.tabBarItem.badgeValue = "5"
        self.tableView.register(InquireContensCell.nib, forCellReuseIdentifier: InquireContensCell.identifier)
        self.tableView.register(InquireHeaderView.nib, forHeaderFooterViewReuseIdentifier: InquireHeaderView.identifier)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        //お知らせ一覧のデータリストを初期化する
        self.visitedInquireList = InquireList(inquires: [])
        self.visitedRefInquireList = {() -> [CmyUserBundle.InquireRef] in
            var list = CmyUserDefault.shared.inquireRefList
            for i in 0..<list.count {
                list[i].collapsed = true
            }
            return list
        }()
        
        self.messageLabel.isHidden = true
        
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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "InquireList.navigationbar.top.title", commenmt: "プライバシー管理")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // お知らせ画面のインスタンスを記録する
        CmyViewController.inquireViewController = self
        
        //既読のお知らせ一覧を更新する
        let refresh_inqRefList: ((InquireList) -> ())! = {(inqList) in
            guard let tmpInqRefList = self.visitedRefInquireList else {return}
            self.visitedRefInquireList.removeAll()
            for inq in inqList.inquires {
                var newInqRef: CmyUserBundle.InquireRef!
                if let idx = tmpInqRefList.index(where: { (inqRef) -> Bool in
                    return inqRef.inquireId == inq.inquireId
                }) {
                    newInqRef = tmpInqRefList[idx]
                    newInqRef.createdAt = inq.createdAt
                } else {
                    // Phase 1 でバッチ消しについはお知らせごとみない
                    // ※ お知らせごと見る場合、各お知らせを展開する時点で行う
                    //newInqRef = CmyUserBundle.InquireRef(inquireId: inq.inquireId!, collapsed: true, readState: false)
                    newInqRef = CmyUserBundle.InquireRef(inquireId: inq.inquireId!, createdAt: inq.createdAt, collapsed: true, readState: true)
                }
                self.visitedRefInquireList.append(newInqRef)
            }
            // Phase 1 でバッチ消しについはお知らせごとみない
            // ※ お知らせごと見る場合、各お知らせを展開する時点で行う
            CmyUserDefault.shared.inquireRefList = self.visitedRefInquireList
        }

        // 読み開いたお知らせ一覧を記録する
        self.myIndicator.startAnimatingEx(sender: nil)
        self.messageLabel.isHidden = true
        CmyAPIClient.fetchInquireList {[weak self](inqireList) in
            self?.myIndicator.stopAnimatingEx(sender: nil)
            guard let weakSelf = self else {return}
            
            weakSelf.visitedInquireList = inqireList
            self?.myIndicator.startAnimatingEx(sender: nil)

            if let list = weakSelf.visitedInquireList, list.inquires.count > 0 {
                // adjust topAnchor if need
                if #available(iOS 11, *) {} else  {
                    weakSelf.tableView.topAnchor.constraint(equalTo: weakSelf.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
                }

                refresh_inqRefList(list)
                weakSelf.tableView.delegate = weakSelf
                weakSelf.tableView.dataSource = weakSelf
                weakSelf.tableView.reloadData()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    weakSelf.messageLabel.isHidden = true
                    
                    // Phase 1 でバッチ消しについはお知らせごとみない
                    // ※ お知らせごと見る場合、各お知らせを展開する時点で行う
                    weakSelf.navigationController?.tabBarItem.badgeValue = nil
                }
                
            } else {
                //データないとき、メッセージラベルを表示する
                weakSelf.tableView.delegate = nil
                weakSelf.tableView.dataSource = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    weakSelf.messageLabel.isHidden = false
                }
            }
            self?.myIndicator.stopAnimatingEx(sender: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CmyViewController.inquireViewController = nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

// MARK: UITableViewDataSource
//
extension CmyInquireListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.visitedInquireList.inquires.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visitedRefInquireList[section].collapsed ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: InquireContensCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: InquireContensCell.identifier, for: indexPath) as? InquireContensCell
        cell?.contentsLabel?.text = self.visitedInquireList.inquires[indexPath.section].inquireContents
        cell?.selectionStyle = .none
        return cell!
    }
}

// MARK: UITableViewDelegate
//
extension CmyInquireListViewController: UITableViewDelegate {
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
    }
    */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: InquireHeaderView.identifier) as? InquireHeaderView {
            let item = self.visitedInquireList.inquires[section]
            
            headerView.titleLabel?.text = item.inquireTitle
            if self.visitedRefInquireList[section].readState {
                headerView.titleLabel?.font = UIFont.systemFont(ofSize: (headerView.titleLabel?.font.pointSize)!)
            } else{
                headerView.titleLabel?.font = UIFont.boldSystemFont(ofSize: (headerView.titleLabel?.font.pointSize)!)
            }
            headerView.createAtLabel?.text = item.createdAt
            headerView.setCollapsed(collapsed: self.visitedRefInquireList[section].collapsed)
            headerView.section = section
            headerView.delegate = self
            
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.cmyTitleColor()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.visitedInquireList.inquires[indexPath.section]
        
        return InquireContensCell.calcContentsHeight(contentString: item.inquireContents!)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
}

extension CmyInquireListViewController: InquireHeaderViewDelegate {
    func toggleSection(headerView: InquireHeaderView, section: Int) {
        let reload_section = {[weak self](section: Int) in
            guard let weakSelf = self else {return}
            weakSelf.tableView.beginUpdates()
            weakSelf.tableView.reloadSections([section], with: .fade)
            weakSelf.tableView.endUpdates()
            let indexPath = IndexPath(row: 0, section: section)
            if let headerView = self?.tableView.headerView(forSection: section) as? InquireHeaderView, !headerView.collapsed {
                weakSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        // Toggle collapse
        
        self.visitedRefInquireList[section].collapsed = !self.visitedRefInquireList[section].collapsed
        /*
        if !self.visitedRefInquireList[section].collapsed &&  !self.visitedRefInquireList[section].readState {
            visitedRefInquireList[section].readState = true
            CmyUserDefault.shared.inquireRefList = self.visitedRefInquireList
            
            // adjust badge number
            // TODO Phase 1で未読件数を出さないとする
            
            self.tabBarItem.badgeValue = {() -> String? in
                var badgeValue: String?
                if let badgeStr = self.tabBarItem.badgeValue, let badgeNum = Int(badgeStr) {
                    //badgeValue = (badgeNum > 1) ? "\(badgeNum - 1)" : nil
                    badgeValue = (badgeNum > 1) ? "" : nil
                }
                return badgeValue
            }()
        }
        */
        
        
        // Adjust the number of the rows inside the section
        reload_section(section)
    }
}

