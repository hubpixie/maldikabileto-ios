//
//  CmyTicketIssuePreviewViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/19.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyTicketIssuePreviewViewController: CmyViewController {

    @IBOutlet weak var ticketQrCodeImageView: UIImageView!
    @IBOutlet weak var sendPresentButton: RoundRectButton!
    @IBOutlet weak var sendButtonLeadingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBottomLayoutConstraint: NSLayoutConstraint!

    var ticketPreviewItem: TicketForAdd!
    var dismissHandler: ((_ ticketItem: TicketListItem?, _ ticketImageData: TicketImageData?)->())!
    /*
    var window: UIWindow?
    lazy var passcode: Passcode = {
        let passcode = Passcode(window: self.window)
        return passcode
    }()
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //チケットプレビュー画像取得API
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
            self.myIndicator.startAnimatingEx(sender: nil)

            //チケットプレビュー画像取得APIの呼び出し
            CmyTicketAPI.getPreviewTicket(
                ticketAmount: self.ticketPreviewItem.ticketAmount!,
                ticketExpirationDate: self.ticketPreviewItem.ticketExpirationDate!,
                ticketTitle: self.ticketPreviewItem.ticketTitle,
                completion: {[weak self] (result, err) in
                    self?.myIndicator.stopAnimatingEx(sender: nil)
                    guard let weakSelf = self else {return}
                    
                    if let err = CmyAPIClient.errorInfo(error: err) {
                        CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.view.check.1", commenmt: "")*/)
                        return
                    }
                    if let result = result {
                        //プレビュー画面を表示
                        // fit a image frame as same ratio
                        
                        if let image_ = UIImage.generateQRCodeWithBase64(from: result.previewTicketImage), let image = UIImage.fitSizedImage(image: image_, widthOffset: 22) {
                            let frame = weakSelf.ticketQrCodeImageView.frame
                            weakSelf.ticketQrCodeImageView.frame = CGRect(x: frame.origin.x + (weakSelf.view.frame.width - 44 - image.size.width) / 2,  y: frame.origin.y, width: image.size.width, height: image.size.height)
                            weakSelf.ticketQrCodeImageView.image = image
                            
                            weakSelf.sendButtonBottomLayoutConstraint.constant += image.size.height - frame.height - 60
                            weakSelf.sendButtonLeadingLayoutConstraint.constant = (weakSelf.view.frame.width - weakSelf.sendPresentButton.frame.width ) / 2
                            weakSelf.view.layoutIfNeeded()
                        }
                        
                        //プレゼントボタンを活性化する
                        weakSelf.sendPresentButton.isEnabled = (weakSelf.ticketQrCodeImageView.image != nil)

                    }
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.navigationbar.top.title", commenmt: "プレビュー")
    }

    override func viewWillDisappear(_ animated: Bool) {
        // タイトル設定
        self.sourceViewController?.resetNavigationItemTitle()
        self.sourceViewController?.seguePrepared = false
        super.viewWillDisappear(animated)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let check_handler = {[weak self]() in
            guard let weakSelf = self else {return}
            if let handler = weakSelf.dismissHandler {
                //チケット発行API
                Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    weakSelf.myIndicator.startAnimatingEx(sender: sender)

                    //チケット発行APIの呼び出し
                    CmyTicketAPI.publishTicket(
                        body: weakSelf.ticketPreviewItem,
                        completion: { (result, error) in
                            weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                            if let err = CmyAPIClient.errorInfo(error: error) {
                                CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/* CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.view.check.2", commenmt: "チケット発行が正しく行えませんでした。")*/)
                                return
                            }
                            
                            //呼び元のコールバックを実施
                            let ticketItem = TicketListItem(
                                ticketNumber: "", //TODO ??
                                ticketType: .gift,
                                ticketStatus: .unused,
                                ticketTitle: weakSelf.ticketPreviewItem.ticketTitle,
                                ticketAmount: weakSelf.ticketPreviewItem.ticketAmount,
                                ticketExpirationDate: weakSelf.ticketPreviewItem.ticketExpirationDate)
                            if let result  = result {
                                weakSelf.myIndicator.startAnimatingEx(sender: sender)
                                //MaldikaBiletoにFcmトークン更新を行う
                                //
                                let updUser = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: nil, password: nil, fcmToken: Messaging.messaging().fcmToken)
                                CmyUserAPI.updateUser(body: updUser, completion: {_, error2 in
                                    weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                                    
                                    if let err2 = CmyAPIClient.errorInfo(error: error2) {
                                        CmyMsgViewController.showError(sender: weakSelf, error:err2, extra:nil/* CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.view.check.2", commenmt: "チケット発行が正しく行えませんでした。")*/)
                                        return
                                    }
                                    handler(ticketItem, result)
                                })
                            }
                            
                    })
                    
                })
                
            }
        }
        
        let mySegue = segue as! CmyPresentSegue
        
        mySegue.extraHandler = {
            if mySegue.destination is CmyPasscodeSettingViewController {
                self.checkPasscodeSetting {
                    check_handler()
                }
            }
        }
    }
        
}
