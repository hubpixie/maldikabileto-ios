//
//  CmyUsedGiftTicketDetailsViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/08.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyUsedGiftTicketDetailsViewController: CmyViewController {

    @IBOutlet weak var ticketNumberLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var ticketAmountlabel: UILabel!
    @IBOutlet weak var ticketStatusLabel: UILabel!
    @IBOutlet weak var ticketExpirationDateLabel: UILabel!
    @IBOutlet weak var ticketPaymentInfoLabel: UILabel!
    @IBOutlet weak var ticketPaymentDateLabel: UILabel!
    @IBOutlet weak var ticketDetaiBackgroundImageView: UIImageView!
    @IBOutlet weak var receiptImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var ticketLogoWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketTitleTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketAmountTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketAmountBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketExpirationDateBottomLayoutConstraint: NSLayoutConstraint!
    
    var ticket: Ticket!
    var dismissHandler: (()->())!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.ticketAmountlabel.superview?.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()
        
        //
        //チケット明細を表示する
        //

        //チケット詳細部の背景イメージサイズを調整
        self.ticketDetaiBackgroundImageView.image = UIImage.fitSizedImage(image: self.ticketDetaiBackgroundImageView.image, widthOffset: 25)

        //チケット：ID
        self.ticketNumberLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketNumber.label", commenmt: "ID:") + self.ticket.ticketNumber
        //チケット作成日
        self.createdAtLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketCreatedAt.label", commenmt: "ID:") + String(self.ticket.createdAt.prefix(10)).replacingOccurrences(of: "-", with: "/")
        // チケットタイトル
        self.ticketTitleLabel.text = self.ticket.ticketTitle
        
        //チケット金額
        // ** 自分で使う場合、金額を表示しない
        if self.ticket.ticketType == Ticket.TicketType.gift {
            self.ticketAmountlabel.text = "\(String.formatCurrencyString(number: self.ticket.ticketAmount!)!) " + CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: "")
            self.ticketAmountlabel.attributedText = {(string: String, subString: String) -> NSAttributedString in
                let attrString = NSMutableAttributedString(string: string)
                let range = (string as NSString).range(of: subString)
                attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: range)
                return attrString
            }(self.ticketAmountlabel.text!, CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: ""))
        } else {
            self.ticketAmountlabel.text = CmyLocaleUtil.shared.localizedMisc(key: "TicketList.amountLabel.private.title", commenmt: "自分で使う")
        }
        
        //チケットステータス
        let statusValues = CmyLocaleUtil.shared.localizedMisc(key: "Common.Ticket.Status", commenmt: "チケットステータス").components(separatedBy: ",")
        let idx: Int? = Ticket.TicketStatus.allValues.index(of: self.ticket.ticketStatus)
        if let idx = idx {
            self.ticketStatusLabel.text = statusValues[idx]
        }
        self.ticketStatusLabel.adjustsFontSizeToFitWidth = true

        //決済日
        self.ticketPaymentDateLabel.adjustsFontSizeToFitWidth = true
        if let paymentAt = self.ticket.paymentedAt {
            self.ticketPaymentDateLabel.text = String(paymentAt.prefix(10)).replacingOccurrences(of: "-", with: "/")
        } else {
            self.ticketPaymentDateLabel.text = ""
        }
        
        //チケット有効期限
        self.ticketExpirationDateLabel.adjustsFontSizeToFitWidth = true
        if self.ticket.ticketExpirationDate != nil {
            self.ticketExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketExpirationDate.label", commenmt: "有効期限") + (self.ticket.ticketExpirationDate?.replacingOccurrences(of: "-", with: "/"))!
        }else {
            self.ticketExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketExpirationDate.label", commenmt: "有効期限")
        }

        //支払い方法
        self.ticketPaymentInfoLabel.adjustsFontSizeToFitWidth = true
        self.ticketPaymentInfoLabel.text = String(format: CmyLocaleUtil.shared.localizedMisc(key: "Common.paymentInfo.label", commenmt: "支払い方法") ,self.ticket.cardCompany + " " + self.ticket.cardInformation)
        
        //レシートQRコードイメージの読み込み
        if let receiptImage = self.ticket.receiptImage {
            if let image_ = UIImage.generateQRCodeWithBase64(from: receiptImage), let image = UIImage.fitSizedImage(image: image_, widthOffset: 16) {
                let frame = self.receiptImageView.frame
                self.receiptImageView.frame = CGRect(x: frame.origin.x + (self.view.frame.width - 16 - image.size.width) / 2, y: frame.origin.y, width: image.size.width, height: image.size.height)
                self.receiptImageView.image = image
              
                let hOffset = frame.height - self.receiptImageView.frame.height
                let frameA = self.receiptImageView.superview!.frame
                self.receiptImageView.superview!.frame = CGRect(x: frameA.origin.x, y: frameA.origin.y, width: frameA.size.width, height: frameA.height - hOffset)
                self.view.layoutIfNeeded()
                
            }
        }
        
        // fit size for iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            let ratio = self.ticketDetaiBackgroundImageView.frame.width / self.ticketDetaiBackgroundImageView.frame.height
            self.ticketTitleTopLayoutConstraint.constant  *= 2 * ratio
            self.ticketAmountTopLayoutConstraint.constant  *= 2 * ratio
            self.ticketAmountBottomLayoutConstraint.constant  *= 2 * ratio
            self.ticketExpirationDateBottomLayoutConstraint.constant  *= 2 * ratio
            self.ticketLogoWidthLayoutConstraint.constant  *= ratio
            self.view.layoutIfNeeded()
        } else if self.view.bounds.width <= 320 {
            self.ticketTitleTopLayoutConstraint.constant  *= 0.2
            self.ticketAmountTopLayoutConstraint.constant  *= 0.2
            self.ticketAmountBottomLayoutConstraint.constant  *= 0.2
            self.ticketExpirationDateBottomLayoutConstraint.constant  *= 0.2
            self.ticketLogoWidthLayoutConstraint.constant *= 0.5
            self.view.layoutIfNeeded()
        }
        // adjust topAnchor if need
        if #available(iOS 11, *) {} else  {
            self.scrollView.superview?.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
            usleep(300 * 1000)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //画面上のスクロール範囲を設定する
        let frame = self.scrollView.frame
        let previewImgPoint = self.receiptImageView.superview!.convert(self.receiptImageView.frame.origin, to: nil)
        let height = self.receiptImageView.frame.height + previewImgPoint.y
        self.scrollView.contentSize = CGSize(width: frame.size.width, height: height  + 10)

        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sourceViewController?.tabBarController?.tabBar.isHidden = false
        if self.sourceViewController != nil &&
            self.sourceViewController! is CmyTicketListViewController {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
        }
        
        //終了時にコールバックを実行する
        if let handle = self.dismissHandler {
            handle()
        }
        super.viewWillDisappear(animated)
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "TicketDetail.navigationbar.top.title", commenmt: "プレビュー")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //チケットの再送信
    //
    @IBAction func resentTicketButtonDidtap(_ sender: UIButton) {
        if let source = self.sourceViewController as? CmyTicketListViewController {
            source.shareTicket(
                data: TicketImageData(ticketImage: self.ticket.receiptImage!),
                ticketItem: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
