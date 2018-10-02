//
//  CmyCreditCardListViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyCreditCardListViewController: CmyViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCardButton: UIButton!
    
    var dismissHandler: ((_ card: Card?)->())!

    private var cardList: CardList!
    private var _selectedIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //Set tableView
        self.tableView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.register(CardInfoTableCell.nib, forCellReuseIdentifier: CardInfoTableCell.identifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // 新しいカード追加
        _ = self.addCardButton.superview?.addBorder(toSide: .top, withColor: UIColor.cmyBottomBorderColor(), andThickness: 1)
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //カード一覧取得
        self.getCreditCardList()
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardList.navigationbar.top.title", commenmt: "クレジットカード管理")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        if !self.seguePrepared {
            self.sourceViewController?.resetNavigationItemTitle()
            self.sourceViewController?.seguePrepared = false
            
            // ナビゲーションバーを非表示する
            if self.sourceViewController is CmyAppSettingsViewController {
                self.sourceViewController?.tabBarController?.tabBar.isHidden = false
            }
        }
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if let handler = self.dismissHandler, let cardList = self.cardList  {
            handler(_selectedIndex >= 0 ? cardList.cards[_selectedIndex] : nil)
        }
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.seguePrepared = true
        
        if segue.destination is CmyCreditCardRegistrationViewController {
            let destVC = segue.destination as! CmyCreditCardRegistrationViewController
            self.clearNavigationItemTitle()
            destVC.sourceViewController = self
            destVC.dismissHandler = {[weak self](card) in
                guard let weakSelf = self else {return}
                if let _ = card {
                    weakSelf.getCreditCardList()
                }
            }
        }

        if segue.destination is CmyCreditCardDetailsViewController,let indexPath = sender as? IndexPath {
            let destVC = segue.destination as! CmyCreditCardDetailsViewController
            self.clearNavigationItemTitle()
            destVC.sourceViewController = self
            destVC.card = self.cardList.cards[indexPath.row]
            destVC.dismissHandler = {[weak self](card) in
                guard let weakSelf = self else {return}
                if let _ = card {
                    weakSelf.getCreditCardList()
                }
            }
        }
    }
    
    // モーダルを閉じる処理
//    @objc func canceDidTap(sender: UIBarButtonItem){
//        self.dismiss(animated: true, completion: nil)
//    }

    // MARK: CARD LIST API CALL
    //クレジット一覧取得
    func getCreditCardList() {
        
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { [weak self] (idToken, error) in
            
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            self?.myIndicator.startAnimatingEx(sender: nil)

            CmyCardAPI.getCardList(completion: {(cardList, err) in
                self?.myIndicator.stopAnimatingEx(sender: nil)
                if let err = CmyAPIClient.errorInfo(error: err) {
//                    var msgExtra = ""
//                    if err.0 == CmyAPIClient.HttpStatusCode.notFound.rawValue {
//                        msgExtra = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardList.view.check.notFound", commenmt: "データなし")
//                    }
                    CmyMsgViewController.showError(sender: self, error:err, extra: nil/*msgExtra*/)
                    return
                }
                self?.cardList = cardList
                self?.tableView.reloadData()
            })
        })
    }

}

// MARK: UITableViewDataSource

extension CmyCreditCardListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardList?.cards.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardInfoTableCell.identifier) as! CardInfoTableCell
        
        // set accessory
        cell.accessoryType = .none
        if self.sourceViewController is CmyAppSettingsViewController {
            cell.accessoryType = .disclosureIndicator
        }
        
        //set selection style
        cell.selectionStyle = .default
        if self.sourceViewController is CmyAppSettingsViewController {
            cell.selectionStyle = .none
        }

        // set cell calue
        cell.defaultCardLabel.text = self.cardList.cards[indexPath.row].defaultCard == Card.DefaultCard.checked ? CmyLocaleUtil.shared.localizedMisc(key: "Common.defaultCard.label", commenmt: "標準") : " "
        cell.cardNumberLabel.text = "\(self.cardList.cards[indexPath.row].cardCompany ?? "") \(self.cardList.cards[indexPath.row].cardNumber)"
        
        return cell
        
    }
}

extension CmyCreditCardListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        _selectedIndex = indexPath.row
        
        //遷移先がある場合
        let cell = tableView.cellForRow(at: indexPath)
        cell?.preventDoubleTap()

        if cell?.accessoryType == .disclosureIndicator {
            self.performSegue(withIdentifier: CmySegueIds.creditCardDetailsSegue.rawValue, sender: indexPath)
        } else {
            //遷移元がある場合
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
}
