//
//  CmyCreditCardDetailsViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyCreditCardDetailsViewController: CmyViewController {

    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardExpirationDateLabel: UILabel!
    @IBOutlet weak var defaultCardButton: UIButton!
    
    var card: Card!
    var dismissHandler: ((_ czrd: Card?)->())!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //set other items
        if let card = card {
            self.cardNumberLabel.text = "\(card.cardCompany ?? "") \(card.cardNumber)"
            self.cardExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.cardExpirationDate.label", commenmt: "有効期限：") + card.cardExpirationDate
            self.defaultCardButton.isHidden = (card.defaultCard != Card.DefaultCard.unchecked)
        }

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
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "CreditCardDetails.navigationbar.top.title", commenmt: "カード詳細情報")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController != nil &&
            self.sourceViewController! is CmyCreditCardListViewController {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
            self.sourceViewController?.seguePrepared = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let handler = self.dismissHandler {
            handler(card)
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

    @IBAction func defaultCardButtonDidTap(_ sender: UIButton) {
        //標準クレジットカード変更APIを呼び出し、当該ボタンを非活性にする
        
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            guard let weakSelf = self else {return}
            self?.myIndicator.startAnimatingEx(sender: sender)
            
            //標準クレジットカード変更API
            CmyCardAPI.changeDefaultCard(
                cardId: weakSelf.card.cardId,
                completion: { (result, error) in
                    self?.myIndicator.stopAnimatingEx(sender: sender)
                    
                    if let err = CmyAPIClient.errorInfo(error: error)  {
                        CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "CreditCardDetails.deleteCard.error.message.1", commenmt: "")*/)
                        return
                    }
                    //変更成功時のメッセージを表示する
                    CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: "CreditCardDetails.defaultCard.change.ok.message", commenmt: ""), title: "", okHandler: {(action) in
                        sender.isHidden = true
                    })
            })
        })
    }
    
    @IBAction func removeCardButtonDidTap(_ sender: UIButton) {
        //クレジットカード削除APIを呼び出し、成功後削除確認画面を終了させる
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            guard let weakSelf = self else {return}
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}

            //クレジットカードか駆除確認画面を開く
            let destVC: CmyCreditCardRemoveConfirmController = CmyCreditCardRemoveConfirmController(card: weakSelf.card)
            destVC.okAction = {() in
                self?.myIndicator.startAnimatingEx(sender: sender)
                CmyCardAPI.deleteCard(
                    cardId: weakSelf.card.cardId,
                    completion: { (result, error) in
                        self?.myIndicator.stopAnimatingEx(sender: sender)

                        if let err = CmyAPIClient.errorInfo(error: error)  {
                            CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "CreditCardDetails.deleteCard.error.message.1", commenmt: "")*/)
                            return
                        }
                        let msgId: String = (weakSelf.card.defaultCard == Card.DefaultCard.checked) ? "CreditCardDetails.deleteCard.ok.message.1" : "CreditCardDetails.deleteCard.ok.message.2"
                        CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: msgId, commenmt: ""), title: "", okHandler: {(action) in
                            weakSelf.navigationController?.popViewController(animated: true)
                        })
                })
            }
            //削除確認画面を表示させる
            weakSelf.present(destVC, animated: true, completion: nil)
        })
    }
    
}
