//
//  CmyIssuedGiftTicketDetailsViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/08/06.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyUnusedGiftTicketDetailsViewController: CmyViewController {

    @IBOutlet weak var ticketNumberLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var ticketAmountlabel: UILabel!
    @IBOutlet weak var ticketStatusLabel: UILabel!
    @IBOutlet weak var ticketStatusImageView: UIImageView!
    @IBOutlet weak var ticketExpirationDateLabel: UILabel!
    @IBOutlet weak var ticketPaymentInfoLabel: UILabel!
    @IBOutlet weak var ticketDetaiBackgroundImageView: UIImageView!
    @IBOutlet weak var ticketPreviewImageView: UIImageView!
    @IBOutlet weak var resentTicketButton: RoundRectFlatButton!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var ticketStatusLabelTrailingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketLogoWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketTitleTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketAmountTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketAmountBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketExpirationDateBottomLayoutConstraint: NSLayoutConstraint!

    var ticket: Ticket!
    var dismissHandler: (()->())!
    
    private let _statusImageNames: [String] = ["ico_used_ticket_white", "ico_expired_white"]
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.ticketAmountlabel.superview?.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //長時間処理インジケータ
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        self.myIndicator.startAnimatingEx(sender: nil)
        //
        //チケット明細を表示する
        //

        //チケット詳細部の背景イメージサイズを調整
        self.ticketDetaiBackgroundImageView.image = UIImage.fitSizedImage(image: self.ticketDetaiBackgroundImageView.image, widthOffset: 16)

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
        self.ticketStatusImageView.image = UIImage(named: self._statusImageNames[0])
        
        let statusValues = CmyLocaleUtil.shared.localizedMisc(key: "Common.Ticket.Status", commenmt: "チケットステータス").components(separatedBy: ",")
        let idx: Int? = Ticket.TicketStatus.allValues.index(of: self.ticket.ticketStatus)
        if let idx = idx {
            self.ticketStatusLabel.text = statusValues[idx]
        }
        self.ticketStatusLabel.adjustsFontSizeToFitWidth = true
        
        //チケット有効期限
        if let expDate = self.ticket.ticketExpirationDate {
            self.ticketExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketExpirationDate.label", commenmt: "有効期限") + (self.ticket.ticketExpirationDate?.replacingOccurrences(of: "-", with: "/"))!
            if Date().toYYYYMMDDStringWithHyphen() > expDate {
                // ステータス(アイコン)
                self.ticketStatusImageView.image = UIImage(named: self._statusImageNames[1])
                // ステータス(文言)
                self.ticketStatusLabel.text = statusValues[TicketInfoCell.expiredIndex]
                //チケットプレビュ- 再送信ボタンを表示しない
                self.ticketPreviewImageView.superview?.isHidden = true
                self.resentTicketButton.isHidden = true
            } else {
                //ステータス（イメージ）の位置調整
                self.ticketStatusLabelTrailingLayoutConstraint.constant += 4
            }

        }else {
            self.ticketExpirationDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketExpirationDate.label", commenmt: "有効期限") 
        }
        
        //支払い方法
        self.ticketPaymentInfoLabel.adjustsFontSizeToFitWidth = true
        self.ticketPaymentInfoLabel.text = String(format: CmyLocaleUtil.shared.localizedMisc(key: "Common.paymentInfo.label", commenmt: "支払い方法") ,self.ticket.cardCompany + " " + self.ticket.cardInformation)
        
        //QRコードイメージの読み込み
        if let ticketImage = self.ticket.ticketImage, self.ticketPreviewImageView.superview?.isHidden == false {
            if let image_ = UIImage.generateQRCodeWithBase64(from: ticketImage), let image = UIImage.fitSizedImage(image: image_, widthOffset: 16) {
                let frame = self.ticketPreviewImageView.frame
                self.ticketPreviewImageView.frame = CGRect(x: frame.origin.x + (self.view.frame.width - 16 - image.size.width) / 2, y: frame.origin.y, width: image.size.width, height: image.size.height)
                self.ticketPreviewImageView.image = image
                
                let hOffset = frame.height - self.ticketPreviewImageView.frame.height
                let frameA = self.ticketPreviewImageView.superview!.frame
                self.ticketPreviewImageView.superview!.frame = CGRect(x: frameA.origin.x, y: frameA.origin.y, width: frameA.size.width, height: frameA.height - hOffset)
                self.view.layoutIfNeeded()
                
            }
        }

        //再送信ボタン
        // ** 自分で使う場合、表示しない
        if self.ticket.ticketType == Ticket.TicketType._private {
            self.resentTicketButton.isHidden = true
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
            self.ticketLogoWidthLayoutConstraint.constant  *= 0.5
            self.view.layoutIfNeeded()
        }
        // adjust topAnchor if need
        if #available(iOS 11, *) {} else  {
            self.scrollView.superview?.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
            usleep(300 * 1000)
        }

        self.myIndicator.stopAnimatingEx(sender: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //画面上のスクロール範囲を設定する
        let frame = self.scrollView.frame
        let previewImgPoint = self.ticketPreviewImageView.superview!.convert(self.ticketPreviewImageView.frame.origin, to: nil)
        let height = self.ticketPreviewImageView.frame.height + previewImgPoint.y
        self.scrollView.contentSize = CGSize(width: frame.size.width, height: height)

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

    //チケットの取り消し
    //
    @IBAction func cancelTicketButtonDidTap(_ sender: UIButton) {
        
        //チケット削除APIを呼び出し、成功後削除確認画面を終了させる
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
            guard let weakSelf = self else {return}
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}

            //チケット削除確認画面を開く
            let destVC: CmyTicketRemoveConfirmController = CmyTicketRemoveConfirmController(ticket: weakSelf.ticket)
            destVC.okAction = {() in
                
                weakSelf.myIndicator.startAnimatingEx(sender: sender)
                CmyTicketAPI.deleteTicket(
                    ticketNumber: weakSelf.ticket.ticketNumber,
                    completion: { (result, error) in
                        weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                        
                        if let err = CmyAPIClient.errorInfo(error: error) {
                            CmyMsgViewController.showError(sender: weakSelf, error: err, extra: nil)
                            return
                        }
                        weakSelf.navigationController?.popViewController(animated: true)
                })
            }
            //削除確認画面を表示させる
            weakSelf.present(destVC, animated: true, completion: nil)
        })

    }
    
    //チケットの再送信
    //
    @IBAction func resentTicketButtonDidtap(_ sender: UIButton) {
        if let source = self.sourceViewController as? CmyTicketListViewController {
            source.shareTicket(
                data: TicketImageData(ticketImage: self.ticket.ticketImage!),
                ticketItem: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
