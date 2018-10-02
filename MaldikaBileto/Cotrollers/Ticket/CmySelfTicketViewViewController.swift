//
//  CmySelfTicketViewViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/23.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmySelfTicketViewViewController: CmyViewController {

    @IBOutlet weak var ticketQrCodeImageView: UIImageView!
    @IBOutlet weak var ticketPaymentInfoLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    @IBOutlet weak var ticketPaymentInfoLabelBottomLayOutConstraint: NSLayoutConstraint!
    
    var imageData: String!
    var card: Card!
    
    var dismissHandler: (()->())!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "SelfTicketView.navigationbar.top.title", commenmt: "自分で使う")

        //QRコードイメージの読み込み
        self.ticketQrCodeImageView.image = UIImage.generateQRCodeWithBase64(from: self.imageData)
        
        if let ticketImage = self.imageData {
            if let image_ = UIImage.generateQRCodeWithBase64(from: ticketImage), let image = UIImage.fitSizedImage(image: image_, widthOffset: 22) {
                let frame = self.ticketQrCodeImageView.frame
                self.ticketQrCodeImageView.frame = CGRect(x: frame.origin.x + (self.view.frame.width - 44 - image.size.width) / 2,  y: frame.origin.y, width: image.size.width, height: image.size.height)
                self.ticketQrCodeImageView.image = image
                
                self.ticketPaymentInfoLabelBottomLayOutConstraint.constant += image.size.height - frame.height - 20
                self.view.layoutIfNeeded()
            }
        }

        //カード情報
        self.ticketPaymentInfoLabel.text = String(format: CmyLocaleUtil.shared.localizedMisc(key: "Common.paymentInfo.label", commenmt: "支払い方法") ,self.card.cardCompany! + " " + self.card.cardNumber)
        self.ticketPaymentInfoLabel.adjustsFontSizeToFitWidth = true
        
        //使い方ラベル
        _ = self.remarkLabel.addBorder(toSide: .top, withColor: UIColor.darkGray.withAlphaComponent(0.2), andThickness: 0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.sourceViewController?.tabBarController?.tabBar.isHidden = false
        if self.sourceViewController != nil &&
            self.sourceViewController! is CmyTicketListViewController {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
        }
        if let handle = self.dismissHandler {
            handle()
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }
    

}
