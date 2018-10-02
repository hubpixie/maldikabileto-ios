//
//  CmyTicketIssueViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyTicketIssueViewController: CmyViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var amountTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var expiryDateTextField: CmyTextFieldDatePicker!
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var ticketTitleTextField: CmyTextFieldBorderExt!
    @IBOutlet weak var nextButton: RoundRectButton!
    @IBOutlet weak var cancelButtonLeftPaddingConstraint: NSLayoutConstraint!

    // アクティブテキストフィールドを保持する
    fileprivate var activeTextField: UITextField!

    private var cardList: CardList!
    private var currentCard: Card!
    
    var dismissHandler: ((_ ticketItem: TicketListItem?, _ ticketImageData: TicketImageData?)->())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //金額
        self.amountTextField.setBottomBorder()
        self.amountTextField.frame.size.height = 55
        self.amountTextField.delegate = self
        
        //使用期限
        self.expiryDateTextField.setupDatePicker(parentView: self.view)
        self.expiryDateTextField.setBottomBorder()
        self.expiryDateTextField.datePicker.date = Date(timeIntervalSinceNow: 7 * 24 * 3600) //7日後
        self.expiryDateTextField.text = self.expiryDateTextField.datePicker.date.toLongDateString()
        //self.expiryDateTextField.pickerDelegate = self
        
        //タイトル
        self.ticketTitleTextField.setBottomBorder()
        self.ticketTitleTextField.delegate = self
        
        //支払い方法
        self.paymentMethodButton.setTitleColor(UIColor.cmyTextColor(), for: .normal)
        self.paymentMethodButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //        thebutton.titleEdgeInsets = UIEdgeInsetsMake(0, -thebutton.imageView.frame.size.width, 0, thebutton.imageView.frame.size.width);
        //        thebutton.imageEdgeInsets = UIEdgeInsetsMake(0, thebutton.titleLabel.frame.size.width, 0, -thebutton.titleLabel.frame.size.width);
        self.paymentMethodButton.titleEdgeInsets = UIEdgeInsetsMake(0, -1 * ((self.paymentMethodButton.imageView?.frame.size.width)! - 15), 0, (self.paymentMethodButton.imageView?.frame.size.width)!)
        self.paymentMethodButton.imageEdgeInsets = UIEdgeInsetsMake(0, ((self.paymentMethodButton.frame.width) - 210), 0, -1 * (self.paymentMethodButton.titleLabel?.frame.size.width)! - 50)

        //_ = self.paymentMethodButton.addBorder(toSide: .bottom, withColor: UIColor.cmyBottomBorderColor(), andThickness: 1)
        self.paymentMethodButton.setViewBottomBorder()
        // layoutの微調整
        self.cancelButtonLeftPaddingConstraint.constant = (self.view.bounds.width - 2 * self.nextButton.frame.width - 34) / 2
        self.scrollView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true

        //長時間処理インジケータ
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //クレジット一覧取得
        getCreditCardList()

        //キーボード制御の初期化
        self.keyboardDelegate = self
    }

    /*
    override func viewDidLayoutSubviews() {
        let frame = self.contentView.frame
        self.contentView.frame = CGRect(x: frame.origin.x,
                                        y:  65,
                                        width: frame.size.width,
                                        height: frame.size.height)
        super.viewDidLayoutSubviews()
    }*/
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.navigationbar.top.title", commenmt: "チケットを発行")
    }

    override func viewWillDisappear(_ animated: Bool) {
        // タイトル設定
        self.sourceViewController?.resetNavigationItemTitle()
        //タブバーを表示する
        self.sourceViewController?.tabBarController?.tabBar.isHidden = self.seguePrepared
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.seguePrepared = true
        
        if self.currentCard != nil && segue.destination is CmyTicketIssuePreviewViewController {
            let destVC = segue.destination as! CmyTicketIssuePreviewViewController
            let inTicketPreviewItem = TicketForAdd(
                ticketType: .gift,
                ticketAmount: Int(self.amountTextField.originalText!),
                ticketTitle: self.ticketTitleTextField.text!,
                ticketExpirationDate: self.expiryDateTextField.text!,
                cardId: self.currentCard.cardId)

            // 次画面呼び出し
            destVC.ticketPreviewItem = inTicketPreviewItem
            destVC.dismissHandler = {[weak self](ticketItem, ticketImageData) in
                guard let weakSelf = self else {return}
                
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    if let handler = weakSelf.dismissHandler {
                        handler(ticketItem, ticketImageData)
                    }
                })
                destVC.navigationController?.popViewController(animated: true)
                CATransaction.commit()
            }
            self.clearNavigationItemTitle()
            destVC.sourceViewController = self
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
        if segue.destination is CmyCreditCardListViewController {
            let destVC = segue.destination as! CmyCreditCardListViewController
            destVC.sourceViewController = self
            self.clearNavigationItemTitle()
            destVC.dismissHandler = {[weak self](card) in
                guard let weakSelf = self else {return}
                if let card = card {
                    weakSelf.currentCard = card
                    weakSelf.paymentMethodButton.setTitle("\(card.cardCompany!) \(card.cardNumber) ", for: .normal)
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //遷移先がチケット発行プレビューの場合、画面入力位チェックを行う
        if identifier == CmySegueIds.ticketIssuePreviewSegue.rawValue {
            return self.validateInputDara()
        }
        return true
    }
    
    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if !(touch.view is UITextField)
        {
            self.view.endEditing(true)
        }
    }


    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        self.dismissHandler = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    //画面入力チェック
    //
    private func validateInputDara() -> Bool {
        self.view.endEditing(true)

        //金額
        //金額のみ入力チェック
        if (self.amountTextField.text ?? "").count < 1 {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.amountTextField.check.1", commenmt: "金額が未入力"), title: "") {[weak self] (action) in
                self?.amountTextField.becomeFirstResponder()
            }
            return false
        }

        var amount: Int = 0
        if let amount_: Int = Int(self.amountTextField.text!) {
            amount = amount_
            self.amountTextField.originalText = "\(amount_)"
            self.amountTextField.text = String.formatCurrencyString(number: amount_)! + CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: "円")
        } else {
            amount = Int(self.amountTextField.originalText ?? "0") ?? 0
        }
        
        //金額の範囲チェック
        if amount > 30000 || amount < 1 {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.amountTextField.check.2", commenmt: "30001円以上"), title: ""){[weak self] (action) in
                self?.amountTextField.becomeFirstResponder()
            }
            return false
        }
        
        //クレジットカード選択チェック
        if self.currentCard == nil {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.paymentMethodButton.check.1", commenmt: "クレジットカードが未選択"), title: "")
            return false
        }
        
        //使用期限（６ヶ月以内。過去日もダメ）
        let dateEnd = Calendar.current.date(byAdding: .month, value: 6, to: Date(timeIntervalSinceNow: -24 * 3600))
        if let dateEnd = dateEnd, self.expiryDateTextField.datePicker.date > dateEnd
            || self.expiryDateTextField.datePicker.date.toLongDateString() < Date().toLongDateString() {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.expiryDateTextField.check.1", commenmt: "使用期限の範囲チェック"), title: "") {[weak self] (action) in
                self?.expiryDateTextField.becomeFirstResponder()
            }
            return false
        }
        
        //チケットタイトルの入力チェックを行う
        guard let title = self.ticketTitleTextField.text, title.count > 0  else {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.ticketTitleTextField.check.1", commenmt: "チケットタイトルが未入力"), title: "") {[weak self] (action) in
                self?.ticketTitleTextField.becomeFirstResponder()
            }
            return false
        }
        if title.count > self.ticketTitleTextField.maxLength  {
            CmyMsgViewController.showMsg(sender: self, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.ticketTitleTextField.check.2", commenmt: "イトルは255文字以内で入力して下さい。"), title: "") {[weak self] (action) in
                self?.ticketTitleTextField.becomeFirstResponder()
            }
            return false
        }
        return true
    }

    // MARK: CARD LIST API CALL
    //クレジット一覧取得
    func getCreditCardList() {
        let card_select = {[weak self](cardList: CardList?) in
            var title: String = CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.paymentMethodButton.title.cardSelect", commenmt: "カード選択")
            guard let weakSelf = self else {return}
            if let card = cardList?.cards.first(where: { (aCard) -> Bool in
                return aCard.defaultCard == Card.DefaultCard.checked
            }) {
                weakSelf.currentCard = card
                title = "\(card.cardCompany!) \(card.cardNumber) "
            }
            weakSelf.paymentMethodButton.setTitle(title, for: .normal)
        }
        
        
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            self.myIndicator.startAnimatingEx(sender: nil)

            CmyCardAPI.getCardList(completion: {[weak self] (cardList, err) in
                self?.myIndicator.stopAnimatingEx(sender: nil)
                guard let weakSelf = self else {return}
                
                if let err = CmyAPIClient.errorInfo(error: err), err.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                    CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.view.check.1", commenmt: "")*/)
                    return
                }
                weakSelf.cardList = cardList!
                card_select(cardList)
            })
        })
    }

}
// MARK: CmyKeyboardDelegate

extension CmyTicketIssueViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.amountTextField {
            self.amountTextField.text = self.amountTextField.originalText
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //使用期限
        if textField is CmyTextFieldDatePicker {
            return false
        }
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.amountTextField {
            if let amount: Int = Int(textField.text!) {
                self.amountTextField.originalText = "\(amount)"
                self.amountTextField.text = String.formatCurrencyString(number: amount)! + CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: "円")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



// MARK: CmyKeyboardDelegate

extension CmyTicketIssueViewController: CmyKeyboardDelegate {
    func keyboardShow(keyboardFrame: CGRect) {
        if self.activeTextField == nil {return}
        let heightOfTextField = self.activeTextField.frame.origin.y + self.activeTextField.frame.height + self.scrollView.frame.origin.y + 100
        let heightOfKbd = UIScreen.main.bounds.size.height - keyboardFrame.size.height
        
        if heightOfTextField >= heightOfKbd {
            self.scrollView.contentOffset.y = heightOfTextField - heightOfKbd
        }
    }
    
    func keyboardHide(keyboardFrame: CGRect) {
        self.scrollView.contentOffset.y = 0
    }
}
